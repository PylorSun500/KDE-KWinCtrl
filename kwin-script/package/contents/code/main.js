/*
 * KWinCtrl Backend — KWin Script
 *
 * Provides window control operations for the KWinCtrl Plasmoid.
 * Communication: D-Bus service (target) / global shortcuts (MVP fallback).
 *
 * Monitor output:
 *   journalctl -b -f -o cat /usr/bin/kwin_wayland | grep -i "kwinctrl"
 */

// ── Utility ──
function log(msg) {
    console.info("KWinCtrl: " + msg);
}

// ── Action dispatcher ──
function execute(action) {
    var win = workspace.activeWindow;
    if (!win) {
        log("No active window — cannot " + action);
        return;
    }

    log(action + " on [" + win.resourceClass + "] " + win.caption);

    switch (action) {
        case "close":
            win.closeWindow();
            break;
        case "minimize":
            win.minimized = !win.minimized;
            break;
        case "maximize":
            workspace.setMaximize(win, true, true);
            break;
        case "fullscreen":
            win.fullScreen = !win.fullScreen;
            break;
        case "keepAbove":
            win.keepAbove = !win.keepAbove;
            break;
        case "keepBelow":
            win.keepBelow = !win.keepBelow;
            break;
        case "onAllDesktops":
            win.onAllDesktops = !win.onAllDesktops;
            break;
        case "skipTaskbar":
            win.skipTaskbar = !win.skipTaskbar;
            break;
        case "skipSwitcher":
            win.skipSwitcher = !win.skipSwitcher;
            break;
        case "quickTileLeft":
            workspace.quickTileWindow(win, "left");
            break;
        case "quickTileRight":
            workspace.quickTileWindow(win, "right");
            break;
        default:
            log("Unknown action: " + action);
    }
}

// ── Global shortcuts (MVP-0/1 fallback) ──
registerShortcut(
    "KWinCtrlClose",
    "KWinCtrl: Close Window",
    "",   // No default keybinding — triggered programmatically
    function () { execute("close"); }
);

// ── D-Bus service (target for MVP-2) ──
// TODO: Once registerService / registerServiceMethod works reliably,
// uncomment the block below and remove the shortcut-based fallback.
//
// registerService("org.kde.kwinctrl", "/Kwinctrl");
// registerServiceMethod("execute", function (action) { execute(action); });
//
// Also register a service to report active window state:
// workspace.windowActivated.connect(function (win) { ... });

log("Script loaded — ready");
