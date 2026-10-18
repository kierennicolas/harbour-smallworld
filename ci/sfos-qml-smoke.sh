#!/bin/bash
# Runs inside the Sailfish OS Platform SDK container.
#  1. Installs the app's runtime dependencies and then the RPM itself into the
#     SDK target, which proves every Requires: resolves on Sailfish OS.
#  2. Checks that every theme icon the QML asks for exists.
#  3. Builds a small harness and loads the installed QML with the real Silica
#     and WebView modules (under qemu): every file must compile, the pages
#     without a web view are created, and a full start is attempted.
set -uo pipefail
: "${SFOS_RELEASE:?}" "${SFOS_ARCH:?}"
TARGET="SailfishOS-${SFOS_RELEASE}-${SFOS_ARCH}"
SB2="sb2 -t $TARGET"
APPQML=/usr/share/harbour-smallworld/qml

shopt -s nullglob
rpms=(/workspace/RPMS/harbour-smallworld-[0-9]*.noarch.rpm)
[ ${#rpms[@]} -eq 1 ] || { echo "::error::expected one app RPM, found: ${rpms[*]:-none}"; exit 2; }

echo "::group::Install dependencies and ${rpms[0]##*/} into $TARGET"
$SB2 -m sdk-install -R zypper --non-interactive refresh >/dev/null 2>&1 || true
deps=$(rpm -qpR "${rpms[0]}" | awk '$1 !~ /^rpmlib\(/ {print $1}' | sort -u)
echo "Requires: $deps"
$SB2 -m sdk-install -R zypper --non-interactive install $deps qt5-plugin-platform-minimal \
  || $SB2 -m sdk-install -R zypper --non-interactive install $deps
# /workspace is not visible in sb2's sdk-install mode; the home directory is.
mkdir -p "$HOME/smoke-rpm" && cp "${rpms[0]}" "$HOME/smoke-rpm/"
if ! $SB2 -m sdk-install -R rpm -Uvh --force "$HOME/smoke-rpm/${rpms[0]##*/}"; then
  echo "::error::The RPM does not install on $TARGET (unresolved Requires?)"
  exit 1
fi
$SB2 rpm -q harbour-smallworld sailfish-components-webview-qt5 sailfishsilica-qt5 libsailfishapp-launcher
echo "::endgroup::"

problems=0

echo "::group::Theme icons used by the app"
themedirs=$($SB2 /bin/sh -c 'ls -d /usr/share/themes/*/meegotouch/z1.0/icons /usr/share/themes/*/silica/z1.0/icons 2>/dev/null')
icons=$(grep -rhoE 'image://theme/[A-Za-z0-9_-]+' "/workspace/qml" | sed 's#image://theme/##' | sort -u)
if [ -z "$themedirs" ]; then
  echo "No theme icon folders in this SDK target; skipping the icon check."
else
  for icon in $icons; do
    found=""
    for d in $themedirs; do
      $SB2 /bin/sh -c "ls $d/$icon.png $d/$icon.svg 2>/dev/null" | grep -q . && found="$d" && break
    done
    if [ -n "$found" ]; then echo "OK      $icon"; else echo "MISSING $icon"; problems=$((problems + 1)); fi
  done
fi
echo "::endgroup::"

SRC="$HOME/smoke-src"
rm -rf "$SRC" && mkdir -p "$SRC"
cp -r /workspace/tests/qmlcheck "$SRC/"
mkdir -p "$SRC/qmlcheck/build" && cd "$SRC/qmlcheck/build"
echo "::group::Build qmlcheck for $TARGET"
$SB2 qmake ../qmlcheck.pro && $SB2 make -j"$(nproc)" || { echo "::error::qmlcheck build failed"; exit 2; }
echo "::endgroup::"

mkdir -p /tmp/xdg && chmod 700 /tmp/xdg
run() { $SB2 /bin/sh -c 'XDG_RUNTIME_DIR=/tmp/xdg QT_QPA_PLATFORM=minimal QV4_FORCE_INTERPRETER=1 ./qmlcheck "$@"' _ "$@"; }

echo "== Compile all QML and create the pages without a web view"
run "$APPQML" || problems=$((problems + 1))

echo "== Full start with the web engine (informational: Gecko under qemu may not start)"
timeout 120 bash -c "$(declare -f run); SB2='$SB2'; run '$APPQML' --full" || echo "(full start did not complete cleanly; not counted)"

echo "qml smoke: $problems problem(s)"
[ $problems -eq 0 ]
