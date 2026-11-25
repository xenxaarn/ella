#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v shellcheck >/dev/null 2>&1; then
	echo "ERROR: shellcheck not found." >&2
	exit 1
fi

echo "==> shellcheck"
shellcheck -S warning build.sh config.sh tools/*.sh root/usr/libexec/ella-branding \
	root/usr/bin/ella-install root/var/lib/livesys/livesys-session-extra
shellcheck -s sh root/etc/fstab.script root/etc/profile.d/editor.sh

echo "==> Ella.kiwi"
python3 - <<'PY'
import sys
import xml.etree.ElementTree as ET

errors = []
root = ET.parse("Ella.kiwi").getroot()

for block in root.findall("packages"):
    names = [e.get("name") for e in block.findall("package")]
    for n in sorted({n for n in names if names.count(n) > 1}):
        errors.append(f"<package name='{n}'> listed twice in one <packages> block")

try:
    from kiwi.xml_description import XMLDescription
    from kiwi.xml_state import XMLState
except ImportError:
    print("note: `kiwi` Python package not installed, skipping schema validation")
else:
    try:
        description = XMLDescription("Ella.kiwi").load()
        state = XMLState(description)
        count = len(state.get_bootstrap_packages()) + len(state.get_system_packages())
        print(f"kiwi schema OK: {count} packages")
    except Exception as exc:
        errors.append(f"KIWI rejected Ella.kiwi: {exc}")

for e in errors:
    print("ERROR:", e, file=sys.stderr)
sys.exit(1 if errors else 0)
PY

echo "lint OK"
