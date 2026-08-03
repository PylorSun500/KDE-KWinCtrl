import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC
import org.kde.taskmanager as TM

PlasmoidItem {
    id: root
    preferredRepresentation: compactRepresentation

    // ── Task model: provides activeTask + requestClose / requestToggleMinimized / ... ──
    TM.TasksModel {
        id: tasksModel
    }

    // ── Compact view: single close button ──
    compactRepresentation: PC.ToolButton {
        icon.name: "window-close"
        onClicked: {
            console.log("[KWinCtrl] close triggered, activeTask:", tasksModel.activeTask)
            tasksModel.requestClose(tasksModel.activeTask)
        }
    }

    // ── Full view: placeholder for MVP-1+ ──
    fullRepresentation: PC.Label {
        text: "KWinCtrl — more actions coming in MVP-2"
        width: 200
        height: 100
    }
}
