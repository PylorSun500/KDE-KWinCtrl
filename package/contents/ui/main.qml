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
    readonly property int checkColW: 22  // checkbox indicator width for text alignment

    // ── Reactive version counter ──
    // tasksModel.data() is NOT reactive in QML bindings (the engine can't know
    // when the model changes internally). We bump this counter on every
    // dataChanged / activeTaskChanged so any binding that references it gets
    // re-evaluated and reads the FRESH window state. This is what makes the
    // checkboxes "window-driven": only the window's real state reaches them.
    property int modelVersion: 0

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
        return tasksModel.data(savedActiveTask, TM.AbstractTasksModel.AppId) || ""
    }

    // ── TEMP DEBUG (commented out — keep for reference) ──
    // function debugSaved() {
    //     if (!savedActiveTask || !savedActiveTask.valid) return "invalid/null"
    //     return tasksModel.data(savedActiveTask, TM.TasksModel.AppId) + "|" + tasksModel.data(savedActiveTask, Qt.DisplayRole)
    // }
    // function debugKeepAbove() {
    //     if (!savedActiveTask || !savedActiveTask.valid) return "invalid"
    //     return "" + tasksModel.data(savedActiveTask, TM.AbstractTasksModel.IsKeepAbove)
    // }

    // Map action id → AdditionalRoles enum value (-1 = one-shot, no checkbox)
    // Enum lookup lives in a function body — reliable QML context, unlike a
    // JS array literal.
    function roleFor(id) {
        switch (id) {
            case "fullscreen":    return TM.AbstractTasksModel.IsFullScreen
            case "keepAbove":     return TM.AbstractTasksModel.IsKeepAbove
            case "keepBelow":     return TM.AbstractTasksModel.IsKeepBelow
            case "shade":         return TM.AbstractTasksModel.IsShaded
            case "noBorder":      return TM.AbstractTasksModel.HasNoBorder
            case "excludeCapture":return TM.AbstractTasksModel.IsExcludedFromCapture
            default:              return -1
        }
    }

    function toggleExpand() {
        if (!expanded) {
            // Capture currently active window BEFORE popup steals focus
            savedActiveTask = tasksModel.activeTask
        }
        expanded = !expanded
    }

    // ── Track active window while popup is open ──
    Connections {
        target: tasksModel
        function onDataChanged() {
            // Window state changed (e.g. keepAbove toggled) → force re-read
            root.modelVersion++
        }
        function onActiveTaskChanged() {
            if (root.expanded && tasksModel.activeTask && tasksModel.activeTask.valid) {
                root.savedActiveTask = tasksModel.activeTask
            }
            root.modelVersion++
        }
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

        // ── TEMP DEBUG (commented out — keep for reference) ──
        // PC.Label {
        //     width: parent.width
        //     text: "v=" + root.modelVersion + " keepAbove=" + root.debugKeepAbove() + " sv=" + root.debugSaved()
        //     font.pixelSize: 9
        //     opacity: 0.7
        // }

        // Action list — declarative, driven by the window's real state.
        // One-shot: PC.ItemDelegate (no checkbox)
        // Toggle:   PC.CheckDelegate (native Breeze checkbox + text)
        // checked binds to tasksModel.data() + root.modelVersion so the ONLY
        // thing that lights a checkbox is the window's actual state.
        Column {
            id: actionCol
            anchors { left: parent.left; right: parent.right; top: sep.bottom }

            Repeater {
                model: [
                    { id: "close",    label: "关闭窗口", run: function(){ tasksModel.requestClose(root.savedActiveTask) } },
                    { id: "minimize", label: "最小化",    run: function(){ tasksModel.requestToggleMinimized(root.savedActiveTask) } },
                    { id: "maximize", label: "最大化",    run: function(){ tasksModel.requestToggleMaximized(root.savedActiveTask) } },
                    { id: "fullscreen",    label: "全屏",                 run: function(){ tasksModel.requestToggleFullScreen(root.savedActiveTask) } },
                    { id: "keepAbove",     label: "保持在其他窗口上方",    run: function(){ tasksModel.requestToggleKeepAbove(root.savedActiveTask) } },
                    { id: "keepBelow",     label: "保持在底层",            run: function(){ tasksModel.requestToggleKeepBelow(root.savedActiveTask) } },
                    { id: "shade",         label: "卷起",                  run: function(){ tasksModel.requestToggleShaded(root.savedActiveTask) } },
                    { id: "noBorder",      label: "无边框",                run: function(){ tasksModel.requestToggleNoBorder(root.savedActiveTask) } },
                    { id: "excludeCapture",label: "在截图与录屏中隐藏",    run: function(){ tasksModel.requestToggleExcludeFromCapture(root.savedActiveTask) } },
                ]
                delegate: ActionRow {}
            }
        }
    }

    // ── Delegate: one row per action ──
    // rowRole < 0 → one-shot (ItemDelegate, no checkbox)
    // rowRole ≥ 0 → toggle   (CheckDelegate, Breeze checkbox bound to window state)
    component ActionRow: Item {
        width: parent ? parent.width : 0
        height: rowImpl.implicitHeight
        property var actionDef: modelData
        property int rowRole: root.roleFor(actionDef.id)  // -1 for one-shot

        // One-shot
        PC.ItemDelegate {
            id: rowImpl
            visible: parent.rowRole < 0
            anchors.fill: parent
            text: parent.actionDef.label
            onClicked: parent.actionDef.run()
        }
        // Toggle — LayoutMirroring moves the Breeze checkbox to the LEFT of the label
        PC.CheckDelegate {
            visible: parent.rowRole >= 0
            anchors.fill: parent
            text: parent.actionDef.label
            LayoutMirroring.enabled: true
            checked: {
                root.modelVersion  // re-evaluate on every window state change
                var idx = root.savedActiveTask
                return idx && idx.valid && tasksModel.data(idx, parent.rowRole) === true
            }
            onToggled: parent.actionDef.run()
        }
    }
}
