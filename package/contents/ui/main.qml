import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC
import org.kde.plasma.core as PlasmaCore
import org.kde.taskmanager as TM

PlasmoidItem {
    id: root
    preferredRepresentation: compactRepresentation

    // ── Layout: width follows content, height fills panel ──
    Layout.minimumWidth: contentWidth
    Layout.preferredWidth: contentWidth
    Layout.fillHeight: true

    // Remove default panel widget margin for edge-to-edge clickability
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // 3 square buttons with spacing: width = 3*h + 2*spacing
    readonly property int contentWidth: 3 * contentHeight + 4

    // Panel gives us full height; contentHeight follows
    property int contentHeight: root.height

    // ── Task model ──
    TM.TasksModel {
        id: tasksModel
    }

    // ── Compact view ──
    compactRepresentation: Row {
        spacing: 2
        // Fill the space allocated by the panel
        anchors.fill: parent

        PC.ToolButton {
            icon.name: "window-minimize"
            display: PC.ToolButton.IconOnly
            height: parent.height
            width: height
            onClicked: tasksModel.requestToggleMinimized(tasksModel.activeTask)
        }
        PC.ToolButton {
            icon.name: "window-maximize"
            display: PC.ToolButton.IconOnly
            height: parent.height
            width: height
            onClicked: tasksModel.requestToggleMaximized(tasksModel.activeTask)
        }
        PC.ToolButton {
            icon.name: "window-close"
            display: PC.ToolButton.IconOnly
            height: parent.height
            width: height
            onClicked: tasksModel.requestClose(tasksModel.activeTask)
        }
    }

    // ── Full view: placeholder for MVP-2 ──
    fullRepresentation: PC.Label {
        text: "KWinCtrl — more actions coming in MVP-2"
        width: 200
        height: 100
    }
}
