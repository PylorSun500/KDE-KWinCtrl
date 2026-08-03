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

    // ── Compact view: minimize / maximize / close ──
    compactRepresentation: Row {
        spacing: 2

        PC.ToolButton {
            icon.name: "window-minimize"
            onClicked: tasksModel.requestToggleMinimized(tasksModel.activeTask)
        }
        PC.ToolButton {
            icon.name: "window-maximize"
            onClicked: tasksModel.requestToggleMaximized(tasksModel.activeTask)
        }
        PC.ToolButton {
            icon.name: "window-close"
            onClicked: tasksModel.requestClose(tasksModel.activeTask)
        }
    }

    // ── Full view: placeholder for MVP-1+ ──
    fullRepresentation: PC.Label {
        text: "KWinCtrl — more actions coming in MVP-2"
        width: 200
        height: 100
    }
}
