import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC
import org.kde.plasma.workspace.dbus as PDBus

PlasmoidItem {
    id: root
    preferredRepresentation: compactRepresentation

    // ── Compact view: single close button ──
    compactRepresentation: PC.ToolButton {
        icon.name: "window-close"
        onClicked: {
            // Build D-Bus message in JS — dbusMessage is a value type
            // and cannot be declared with QML object syntax.
            var msg = PDBus.DBusMessage()
            msg.service = "org.kde.KWin"
            msg.path = "/KWin"
            msg.iface = "org.kde.KWin"
            msg.member = "killWindow"

            console.log("[KWinCtrl] killWindow triggered")
            PDBus.SessionBus.asyncCall(msg)
        }
    }

    // ── Full view: placeholder for MVP-1+ ──
    fullRepresentation: PC.Label {
        text: "KWinCtrl — more actions coming in MVP-2"
        width: 200
        height: 100
    }
}
