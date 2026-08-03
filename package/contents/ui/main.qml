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

    // ── Layout: width follows content, height fills panel ──
    Layout.minimumWidth: contentWidth
    Layout.preferredWidth: contentWidth
    Layout.fillHeight: true
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // 4 buttons with spacing: width = 4*h + 3*spacing(2px)
    readonly property int contentWidth: 4 * contentHeight + 6
    property int contentHeight: root.height

    // ── Task model ──
    TM.TasksModel {
        id: tasksModel
    }

    // ── Expand / collapse ──
    function toggleExpand() {
        expanded = !expanded
    }

    // ── Helper: read window state role ──
    function isOn(role) {
        var idx = tasksModel.activeTask
        if (!idx || !idx.valid) return false
        return tasksModel.data(idx, role) === true
    }

    function windowTitle() {
        var idx = tasksModel.activeTask
        if (!idx || !idx.valid) return ""
        return tasksModel.data(idx, Qt.DisplayRole) || ""
    }

    function appId() {
        var idx = tasksModel.activeTask
        if (!idx || !idx.valid) return ""
        return tasksModel.data(idx, TM.TasksModel.AppId) || ""
    }

    // ── Compact view ──
    compactRepresentation: Row {
        spacing: 2
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
        PC.ToolButton {
            icon.name: "overflow-menu"
            display: PC.ToolButton.IconOnly
            height: parent.height
            width: height
            onClicked: root.toggleExpand()
        }
    }

    // ── Full view ──
    fullRepresentation: Item {
        implicitWidth: 240
        implicitHeight: headerRow.height + 1 + actionCol.height + 12

        // ── Header: app icon + window title ──
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

        // ── Separator ──
        Rectangle {
            id: sep
            anchors { left: parent.left; right: parent.right; top: headerRow.bottom }
            height: 1
            color: Kirigami.Theme.textColor
            opacity: 0.15
        }

        // ── Action list ──
        Column {
            id: actionCol
            anchors { left: parent.left; right: parent.right; top: sep.bottom }

            // One-shot actions
            ActionItem { label: "关闭窗口";               onTriggered: tasksModel.requestClose(tasksModel.activeTask) }
            ActionItem { label: "最小化";                onTriggered: tasksModel.requestToggleMinimized(tasksModel.activeTask) }
            ActionItem { label: "最大化";                onTriggered: tasksModel.requestToggleMaximized(tasksModel.activeTask) }

            // Toggle actions — inline binding to tasksModel.activeTask ensures reactive updates
            ToggleItem {
                label: "全屏"
                toggled: { tasksModel.activeTask; return root.isOn(TM.TasksModel.IsFullScreen) }
                onTriggered: tasksModel.requestToggleFullScreen(tasksModel.activeTask)
            }
            ToggleItem {
                label: "保持在其他窗口上方"
                toggled: { tasksModel.activeTask; return root.isOn(TM.TasksModel.IsKeepAbove) }
                onTriggered: tasksModel.requestToggleKeepAbove(tasksModel.activeTask)
            }
            ToggleItem {
                label: "保持在底层"
                toggled: { tasksModel.activeTask; return root.isOn(TM.TasksModel.IsKeepBelow) }
                onTriggered: tasksModel.requestToggleKeepBelow(tasksModel.activeTask)
            }
            ToggleItem {
                label: "卷起"
                toggled: { tasksModel.activeTask; return root.isOn(TM.TasksModel.IsShaded) }
                onTriggered: tasksModel.requestToggleShaded(tasksModel.activeTask)
            }
            ToggleItem {
                label: "无边框"
                toggled: { tasksModel.activeTask; return root.isOn(TM.TasksModel.HasNoBorder) }
                onTriggered: tasksModel.requestToggleNoBorder(tasksModel.activeTask)
            }
            ToggleItem {
                label: "在截图与录屏中隐藏"
                toggled: { tasksModel.activeTask; return root.isOn(TM.TasksModel.IsExcludedFromCapture) }
                onTriggered: tasksModel.requestToggleExcludeFromCapture(tasksModel.activeTask)
            }
        }
    }

    // ── Delegate: one-shot action ──
    component ActionItem: PC.ItemDelegate {
        id: actionDelegate
        implicitHeight: 32
        signal triggered()

        contentItem: PC.Label {
            text: actionDelegate.label
            verticalAlignment: Text.AlignVCenter
        }
        required property string label
        onClicked: actionDelegate.triggered()
    }

    // ── Delegate: toggle action (checkbox) ──
    component ToggleItem: PC.ItemDelegate {
        id: toggleDelegate
        implicitHeight: 32
        signal triggered()

        required property string label
        property bool toggled: false  // "checked" conflicts with ItemDelegate's FINAL property

        contentItem: RowLayout {
            spacing: 8
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
