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
        implicitWidth: 240
        implicitHeight: headerRow.height + 1 + actionCol.height + 16

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

        // Action list — use savedActiveTask so actions work even when popup has focus
        Column {
            id: actionCol
            anchors { left: parent.left; right: parent.right; top: sep.bottom }

            RowAction {
                label: "关闭窗口"
                onTriggered: tasksModel.requestClose(root.savedActiveTask)
            }
            RowAction {
                label: "最小化"
                onTriggered: tasksModel.requestToggleMinimized(root.savedActiveTask)
            }
            RowAction {
                label: "最大化"
                onTriggered: tasksModel.requestToggleMaximized(root.savedActiveTask)
            }

            ToggleAction {
                label: "全屏"
                toggled: { root.savedActiveTask; return root.isOn(TM.TasksModel.IsFullScreen) }
                onTriggered: tasksModel.requestToggleFullScreen(root.savedActiveTask)
            }
            ToggleAction {
                label: "保持在其他窗口上方"
                toggled: { root.savedActiveTask; return root.isOn(TM.TasksModel.IsKeepAbove) }
                onTriggered: tasksModel.requestToggleKeepAbove(root.savedActiveTask)
            }
            ToggleAction {
                label: "保持在底层"
                toggled: { root.savedActiveTask; return root.isOn(TM.TasksModel.IsKeepBelow) }
                onTriggered: tasksModel.requestToggleKeepBelow(root.savedActiveTask)
            }
            ToggleAction {
                label: "卷起"
                toggled: { root.savedActiveTask; return root.isOn(TM.TasksModel.IsShaded) }
                onTriggered: tasksModel.requestToggleShaded(root.savedActiveTask)
            }
            ToggleAction {
                label: "无边框"
                toggled: { root.savedActiveTask; return root.isOn(TM.TasksModel.HasNoBorder) }
                onTriggered: tasksModel.requestToggleNoBorder(root.savedActiveTask)
            }
            ToggleAction {
                label: "在截图与录屏中隐藏"
                toggled: { root.savedActiveTask; return root.isOn(TM.TasksModel.IsExcludedFromCapture) }
                onTriggered: tasksModel.requestToggleExcludeFromCapture(root.savedActiveTask)
            }
        }
    }

    // ── Delegate: one-shot row action ──
    component RowAction: PC.ItemDelegate {
        id: rowDelegate
        implicitHeight: 32
        signal triggered()

        required property string label

        contentItem: PC.Label {
            text: rowDelegate.label
            verticalAlignment: Text.AlignVCenter
            leftPadding: Kirigami.Units.mediumSpacing
        }
        onClicked: rowDelegate.triggered()
    }

    // ── Delegate: toggle row action (with checkbox) ──
    component ToggleAction: PC.ItemDelegate {
        id: toggleDelegate
        implicitHeight: 32
        signal triggered()

        required property string label
        property bool toggled: false

        contentItem: RowLayout {
            spacing: 0
            PC.CheckBox {
                checked: toggleDelegate.toggled
                onToggled: toggleDelegate.triggered()
            }
            PC.Label {
                Layout.fillWidth: true
                text: toggleDelegate.label
                verticalAlignment: Text.AlignVCenter
            }
        }
        onClicked: toggleDelegate.triggered()
    }
}
