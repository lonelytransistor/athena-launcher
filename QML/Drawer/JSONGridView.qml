import QtQuick 2.6
import QtQuick.Controls 2.4

GridView {
    id: root
    anchors.fill: parent
    property var availableApps: []
    property var runningApps: []
    property string availableApps_cache: "[]"
    property string runningApps_cache: "[]"
    property bool filter: false
    
    property int lastDirScroll: -1
    
    function includes(obj, it) {
        for (var n=0; n<obj.length; n++) {
            if (obj[n] == it) {
                return true;
            }
        }
        return false;
    }
    onAvailableAppsChanged: {
        model.clear();
        for (var n=0; n<availableApps.length; n++) {
            if (!filter || (availableApps[n].running == true)) {
                availableApps[n].running = (availableApps[n].running == true);
                model.append(availableApps[n]);
            }
        }
        availableApps_cache = JSON.stringify(availableApps);
    }
    onRunningAppsChanged: {
        for (var n=0; n<availableApps.length; n++) {
            availableApps[n].running = includes(runningApps, availableApps[n].name);
        }
        for (var n=0; n<model.count; n++) {
            model.setProperty(n, "running", includes(runningApps, model.get(n).name));
        }
        runningApps_cache = JSON.stringify(runningApps);
    }

    model: ListModel{}
    snapMode: GridView.SnapOneRow
    focus: false
    interactive: false
    highlightMoveDuration: 0
    leftMargin: (width-Math.floor(width/cellWidth)*cellWidth)/2
    rightMargin: leftMargin
    
    signal scrollDown()
    signal scrollUp()
    
    onScrollUp: {
        if (root.lastDirScroll == 1) {
            root.lastDirScroll = -1
            root.currentIndex = Math.max(root.currentIndex-Math.floor(root.width/root.cellWidth)*Math.floor(root.height/root.cellHeight)*2+1, 0)
        } else {
            root.currentIndex = Math.max(root.currentIndex-Math.floor(root.width/root.cellWidth)*Math.floor(root.height/root.cellHeight), 0)
        }
    }
    onScrollDown: {
        if (root.lastDirScroll == -1) {
            root.lastDirScroll = 1
            root.currentIndex = Math.min(root.currentIndex+Math.floor(root.width/root.cellWidth)*Math.floor(root.height/root.cellHeight)*2-1, root.model.count-1)
        } else {
            root.currentIndex = Math.min(root.currentIndex+Math.floor(root.width/root.cellWidth)*Math.floor(root.height/root.cellHeight), root.model.count-1)
        }
    }
}
