#!/bin/bash
# KWinCtrl — Install script (MVP-0)
# Installs both the Plasmoid and the KWin Script backend.

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLASMOID_PACKAGE="$PROJECT_DIR/package"
KWIN_SCRIPT_PACKAGE="$PROJECT_DIR/kwin-script/package"
KWIN_SCRIPT_ID="org.kde.kwinctrl"
KWIN_SCRIPT_DIR="$HOME/.local/share/kwin/scripts/$KWIN_SCRIPT_ID"

echo "=== KWinCtrl MVP-0 Install ==="
echo ""

# ── 1. Install Plasmoid ──
echo "[1/3] Installing Plasmoid..."
kpackagetool6 -t Plasma/Applet --install "$PLASMOID_PACKAGE" 2>&1 || \
    kpackagetool6 -t Plasma/Applet --upgrade "$PLASMOID_PACKAGE" 2>&1
echo "  → Installed to ~/.local/share/plasma/plasmoids/$KWIN_SCRIPT_ID/"
echo ""

# ── 2. Install KWin Script ──
echo "[2/3] Installing KWin Script..."
mkdir -p "$KWIN_SCRIPT_DIR"
cp -r "$KWIN_SCRIPT_PACKAGE/"* "$KWIN_SCRIPT_DIR/"
echo "  → Installed to $KWIN_SCRIPT_DIR/"
echo ""

# ── 3. Enable KWin Script in kwinrc ──
echo "[3/3] Enabling KWin Script..."
kwriteconfig6 --file kwinrc --group "Script-$KWIN_SCRIPT_ID" --key enabled true
echo "  → Script enabled in ~/.config/kwinrc"
echo ""

echo "=== Installation complete ==="
echo ""
echo "Next steps:"
echo ""
echo "  1. Reload KWin scripts:"
echo "     gdbus call --session --dest org.kde.KWin --object-path /Scripting --method org.kde.kwin.Scripting.start"
echo ""
echo "  2. Add the widget to your panel:"
echo "     Right-click panel → Add Widget → search 'KWinCtrl'"
echo ""
echo "  3. Test the close button with a disposable window:"
echo "     Click [✕] → window should close"
echo ""
echo "  4. Monitor logs if something goes wrong:"
echo "     journalctl -b -f -o cat /usr/bin/plasmashell | grep -i kwinctrl"
echo "     journalctl -b -f -o cat /usr/bin/kwin_wayland | grep -i kwinctrl"
