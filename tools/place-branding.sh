#!/usr/bin/env bash
#   branding/logo.png      -> root/usr/share/pixmaps/ella.png
#   branding/wallpaper.png -> root/usr/share/wallpapers/Ella/
set -euo pipefail

cd "$(dirname "$0")/.."

LOGO_SRC="branding/logo.png"
WALL_SRC="branding/wallpaper.png"
PIXMAPS="root/usr/share/pixmaps"
WALL_DIR="root/usr/share/wallpapers/Ella"

png_size() {
  local magic
  magic=$(od -An -tx1 -N8 "$1" | tr -d ' \n')
  [ "$magic" = "89504e470d0a1a0a" ] || {
    echo "ERROR: $1 is not a PNG" >&2
    return 1
  }
  od -An -tu4 --endian=big -j16 -N8 "$1" | tr -s ' ' | sed 's/^ //'
}

placed=()

if [ -f "$LOGO_SRC" ]; then
  png_size "$LOGO_SRC" >/dev/null
  install -D -m 0644 "$LOGO_SRC" "$PIXMAPS/ella.png"
  placed+=("$PIXMAPS")
else
  echo "warning: $LOGO_SRC not found, skipping logo" >&2
fi

if [ -f "$WALL_SRC" ]; then
  read -r w h < <(png_size "$WALL_SRC")
  rm -rf -- "$WALL_DIR"
  install -D -m 0644 "$WALL_SRC" "$WALL_DIR/contents/images/${w}x${h}.png"
  cat >"$WALL_DIR/metadata.json" <<'JSON'
{
    "KPackageStructure": "Wallpaper/Images",
    "KPlugin": {
        "Authors": [
            {
                "Name": "xenxaarn"
            }
        ],
        "Id": "Ella",
        "Name": "Ella"
    }
}
JSON
  chmod 0644 "$WALL_DIR/metadata.json"
  placed+=("root/usr/share/wallpapers")
else
  echo "warning: $WALL_SRC not found, skipping wallpaper" >&2
fi

if [ -n "${SUDO_UID:-}" ] && [ "${#placed[@]}" -gt 0 ]; then
  chown -R "$SUDO_UID:${SUDO_GID:-$SUDO_UID}" "${placed[@]}"
fi

echo "==> Branding placed (logo: $([ -f "$PIXMAPS/ella.png" ] && echo yes || echo no), wallpaper: $([ -d "$WALL_DIR" ] && echo yes || echo no))"
