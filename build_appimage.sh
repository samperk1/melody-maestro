#!/bin/bash
set -e

APPNAME="MelodyMaestro"
VERSION="1.0.0"
ARCH="x86_64"
APPDIR="AppDir"

echo "=== Melody Maestro AppImage Builder ==="

# 1. Export Linux binary from Godot
echo "[1/4] Exporting Linux binary..."
mkdir -p builds/linux
~/Desktop/Godot_v4.6.2-stable_linux.x86_64 --headless --export-release "Linux/X11" builds/linux/MelodyMaestro.x86_64

# 2. Build AppDir structure
echo "[2/4] Building AppDir..."
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

# Copy actual binary with different name
cp builds/linux/MelodyMaestro.x86_64 "$APPDIR/usr/bin/melody-maestro.bin"
chmod +x "$APPDIR/usr/bin/melody-maestro.bin"

# Wrapper script so env vars apply even if AppRun is bypassed
cat > "$APPDIR/usr/bin/melody-maestro" << 'WRAPPER'
#!/bin/bash
export AT_SPI_BUS_ADDRESS=""
export NO_AT_BRIDGE=1
export GNOME_ACCESSIBILITY=0
unset DRI_PRIME
DIR="$(dirname "$(readlink -f "$0")")"
exec "$DIR/melody-maestro.bin" "$@"
WRAPPER
chmod +x "$APPDIR/usr/bin/melody-maestro"

# Icon — use the screenshot PNG as icon until a proper icon is made
cp melody_maestro_startscreen.png "$APPDIR/usr/share/icons/hicolor/256x256/apps/melody-maestro.png"
cp melody_maestro_startscreen.png "$APPDIR/melody-maestro.png"

# .desktop file
cat > "$APPDIR/usr/share/applications/melody-maestro.desktop" << 'EOF'
[Desktop Entry]
Name=Melody Maestro
Comment=Piano learning game — pop balloons and fight monsters
Exec=melody-maestro
Icon=melody-maestro
Type=Application
Categories=Game;Music;
Keywords=piano;music;learning;midi;
EOF

cp "$APPDIR/usr/share/applications/melody-maestro.desktop" "$APPDIR/melody-maestro.desktop"

# AppRun launcher
cat > "$APPDIR/AppRun" << 'APPRUN'
#!/bin/bash
HERE="$(dirname "$(readlink -f "$0")")"
export AT_SPI_BUS_ADDRESS=""
export NO_AT_BRIDGE=1
export GNOME_ACCESSIBILITY=0
unset DRI_PRIME
exec "$HERE/usr/bin/melody-maestro" "$@"
APPRUN
chmod +x "$APPDIR/AppRun"

# 3. Download appimagetool if not present
echo "[3/4] Checking for appimagetool..."
if ! command -v appimagetool &>/dev/null; then
    if [ ! -f appimagetool-x86_64.AppImage ]; then
        echo "Downloading appimagetool..."
        curl -Lo appimagetool-x86_64.AppImage \
            "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
        chmod +x appimagetool-x86_64.AppImage
    fi
    APPIMAGETOOL="./appimagetool-x86_64.AppImage"
else
    APPIMAGETOOL="appimagetool"
fi

# 4. Package AppImage
echo "[4/4] Packaging AppImage..."
ARCH=$ARCH $APPIMAGETOOL "$APPDIR" "builds/linux/${APPNAME}-${VERSION}-${ARCH}.AppImage"

echo ""
echo "Done: builds/linux/${APPNAME}-${VERSION}-${ARCH}.AppImage"
