import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC
import org.kde.plasma.core as PlasmaCore
import org.kde.taskmanager as TM
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    preferredRepresentation: compactRepresentation

    // ── Layout ──
    Layout.minimumWidth: contentWidth
    Layout.preferredWidth: contentWidth
    Layout.fillHeight: true
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    readonly property int contentWidth: 4 * contentHeight + 6
    property int contentHeight: root.height

    // ── Task model ──
    TM.TasksModel {
        id: tasksModel
    }

    // ── Saved target window (captured before popup steals focus) ──
    property var savedActiveTask: null

    function isOn(role) {
        if (!savedActiveTask || !savedActiveTask.valid) return false
        return tasksModel.data(savedActiveTask, role) === true
    }

    function windowTitle() {
        if (!savedActiveTask || !savedActiveTask.valid) return ""
        return tasksModel.data(savedActiveTask, Qt.DisplayRole) || ""
    }

    function appId() {
        if (!savedActiveTask || !savedActiveTask.valid) return ""
        return tasksModel.data(savedActiveTask, TM.TasksModel.AppId) || ""
    }

    function toggleExpand() {
        if (!expanded) {
            // Capture currently active window BEFORE popup steals focus
            savedActiveTask = tasksModel.activeTask
        }
        expanded = !expanded
    }

    // ── Compact view ──
    compactRepresentation: Row {
        spacing: 2
        anchors.fill: parent

        PC.ToolButton {
            icon.name: "window-minimize"
            display: PC.ToolButton.IconOnly
            height: parent.height; width: height
            onClicked: tasksModel.requestToggleMinimized(tasksModel.activeTask)
        }
        PC.ToolButton {
            icon.name: "window-maximize"
            display: PC.ToolButton.IconOnly
            height: parent.height; width: height
            onClicked: tasksModel.requestToggleMaximized(tasksModel.activeTask)
        }
        PC.ToolButton {
            icon.name: "window-close"
            display: PC.ToolButton.IconOnly
            height: parent.height; width: height
            onClicked: tasksModel.requestClose(tasksModel.activeTask)
        }
        PC.ToolButton {
            icon.name: "overflow-menu"
            display: PC.ToolButton.IconOnly
            height: parent.height; width: height
            onClicked: root.toggleExpand()
        }
    }

    // ── Full view ──
    fullRepresentation: Item {
        implicitWidth: 220
        implicitHeight: headerRow.height + 1 + actionCol.height + 12

        // Header
        RowLayout {
            id: headerRow
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: 8
            spacing: 8

            Kirigami.Icon {
                Layout.preferredWidth: 22; Layout.preferredHeight: 22
                source: root.appId()
            }
            PC.Label {
                Layout.fillWidth: true
                text: root.windowTitle()
                elide: Text.ElideRight
            }
        }

        // Separator
        Rectangle {
            id: sep
            anchors { left: parent.left; right: parent.right; top: headerRow.bottom }
            height: 1
            color: Kirigami.Theme.textColor
            opacity: 0.15
        }

        // Action list — vertical ToolButtons, same style as compact view
        Column {
            id: actionCol
            anchors { left: parent.left; right: parent.right; top: sep.bottom }

            PC.ToolButton {
                width: parent.width
                text: "关闭窗口"
                icon.name: "window-close"
                display: PC.ToolButton.TextBesideIcon
                onClicked: tasksModel.requestClose(root.savedActiveTask)
            }
            PC.ToolButton {
                width: parent.width
                text: "最小化"
                icon.name: "window-minimize"
                display: PC.ToolButton.TextBesideIcon
                onClicked: tasksModel.requestToggleMinimized(root.savedActiveTask)
            }
            PC.ToolButton {
                width: parent.width
                text: "最大化"
                icon.name: "window-maximize"
                display: PC.ToolButton.TextBesideIcon
                onClicked: tasksModel.requestToggleMaximized(root.savedActiveTask)
            }

            PC.ToolButton {
                width: parent.width
                text: "全屏"
                icon.name: "view-fullscreen"
                display: PC.ToolButton.TextBesideIcon
                checkable: true
                checked: { root.savedActiveTask; return root.isOn(TM.TasksModel.IsFullScreen) }
                onToggled: tasksModel.requestToggleFullScreen(root.savedActiveTask)
            }
            PC.ToolButton {
                width: parent.width
                text: "保持在其他窗口上方"
                icon.name: "window-keep-above"
                display: PC.ToolButton.TextBesideIcon
                checkable: true
                checked: { root.savedActiveTask; return root.isOn(TM.TasksModel.IsKeepAbove) }
                onToggled: tasksModel.requestToggleKeepAbove(root.savedActiveTask)
            }
            PC.ToolButton {
                width: parent.width
                text: "保持在底层"
                icon.name: "window-keep-below"
                display: PC.ToolButton.TextBesideIcon
                checkable: true
                checked: { root.savedActiveTask; return root.isOn(TM.TasksModel.IsKeepBelow) }
                onToggled: tasksModel.requestToggleKeepBelow(root.savedActiveTask)
            }
            PC.ToolButton {
                width: parent.width
                text: "卷起"
                icon.name: "window-shade"
                display: PC.ToolButton.TextBesideIcon
                checkable: true
                checked: { root.savedActiveTask; return root.isOn(TM.TasksModel.IsShaded) }
                onToggled: tasksModel.requestToggleShaded(root.savedActiveTask)
            }
            PC.ToolButton {
                width: parent.width
                text: "无边框"
                icon.name: "window-noborder"
                display: PC.ToolButton.TextBesideIcon
                checkable: true
                checked: { root.savedActiveTask; return root.isOn(TM.TasksModel.HasNoBorder) }
                onToggled: tasksModel.requestToggleNoBorder(root.savedActiveTask)
            }
            PC.ToolButton {
                width: parent.width
                text: "在截图与录屏中隐藏"
                icon.name: "window-hide-capture"
                display: PC.ToolButton.TextBesideIcon
                checkable: true
                checked: { root.savedActiveTask; return root.isOn(TM.TasksModel.IsExcludedFromCapture) }
                onToggled: tasksModel.requestToggleExcludeFromCapture(root.savedActiveTask)
            }
        }
    }
}
