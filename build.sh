#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

CLEAN_DEFAULT_OUTPUT=0
if [ -z "${OUTPUT_DIR:-}" ]; then
  OUTPUT_DIR="output"
  CLEAN_DEFAULT_OUTPUT=1
fi
CONTAINER_IMAGE="${CONTAINER_IMAGE:-registry.fedoraproject.org/fedora:45}"
BOX="${BOX:-}"
MODE="container"

usage() {
  cat <<USAGE
Usage: $0 [--native] [--boxbuild] [--output <dir>] [--box <n>]

  (no flag)   Build inside a privileged Fedora 45 container (Podman/Docker).
  --native    Build directly on a Fedora 45 host (needs root).
  --boxbuild  Build in a self-contained KIWI box (needs root and --box).

  --output    Directory for build artefacts (default: output).
  --box       Box name for --boxbuild (see 'kiwi-ng system boxbuild --list-boxes').
USAGE
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
  --native) MODE="native" ;;
  --boxbuild) MODE="boxbuild" ;;
  --output)
    OUTPUT_DIR="${2:?--output needs a value}"
    CLEAN_DEFAULT_OUTPUT=0
    shift
    ;;
  --box)
    BOX="${2:?--box needs a value}"
    shift
    ;;
  -h | --help) usage 0 ;;
  *)
    echo "Unknown option: $1" >&2
    usage 1
    ;;
  esac
  shift
done

if [ "$CLEAN_DEFAULT_OUTPUT" -eq 1 ]; then
  rm -rf -- "$OUTPUT_DIR"
fi
mkdir -p "$OUTPUT_DIR/kiwi-tmp"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: $1 needs root; re-run with sudo." >&2
    exit 1
  fi
}

require_kiwi() {
  if ! command -v kiwi-ng >/dev/null 2>&1; then
    echo "ERROR: kiwi-ng not found. Install KIWI NG on a Fedora 45 host:" >&2
    echo "  sudo dnf install kiwi kiwi-systemdeps-iso-media distribution-gpg-keys" >&2
    exit 1
  fi
}

if [ "$MODE" = "native" ]; then
  require_root --native
  require_kiwi
  echo "==> Building natively"
  kiwi-ng --temp-dir "$OUTPUT_DIR/kiwi-tmp" system build \
    --description . \
    --target-dir "$OUTPUT_DIR"

elif [ "$MODE" = "boxbuild" ]; then
  require_root --boxbuild
  require_kiwi
  if [ -z "$BOX" ]; then
    echo "ERROR: --boxbuild requires --box <n>." >&2
    echo "List available boxes with: kiwi-ng system boxbuild --list-boxes" >&2
    exit 1
  fi
  echo "==> Box building with box: $BOX"
  kiwi-ng --temp-dir "$OUTPUT_DIR/kiwi-tmp" system boxbuild \
    --box "$BOX" \
    -- system build \
    --description . \
    --target-dir "$OUTPUT_DIR"

else
  if command -v podman >/dev/null 2>&1; then
    RUNNER=(podman run --rm --privileged --network=host --pull=newer)
  elif command -v docker >/dev/null 2>&1; then
    RUNNER=(docker run --rm --privileged --network=host --pull always)
  else
    echo "ERROR: neither podman nor docker found. Install one to build." >&2
    exit 1
  fi
  RUNNER+=(--security-opt label=type:unconfined_t)
  RUNNER+=(-v "$PWD:$PWD" -v "$OUTPUT_DIR:$OUTPUT_DIR" -w "$PWD")

  OWNER="${SUDO_UID:-$(id -u)}:${SUDO_GID:-$(id -g)}"

  echo "==> Building inside privileged container ($CONTAINER_IMAGE)"
  "${RUNNER[@]}" "$CONTAINER_IMAGE" \
    bash "$PWD/tools/container-build.sh" "$OUTPUT_DIR" "$OWNER"
fi

echo
(
  cd "$OUTPUT_DIR"
  find . -maxdepth 3 -type f -name '*.iso' -printf '%P\0' | sort -z | xargs -0 -r sha256sum >SHA256SUMS
  if [ ! -s SHA256SUMS ]; then
    echo "ERROR: build finished but no ISO was produced." >&2
    exit 1
  fi
  echo "==> Build complete. Output in: $OUTPUT_DIR"
  find . -maxdepth 3 -type f \( -name '*.iso' -o -name SHA256SUMS \) -exec ls -lh {} \;
)
