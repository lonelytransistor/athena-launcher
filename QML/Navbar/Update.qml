import QtQuick 2.0
import com.remarkable 1.0

import "." as N
import Athena 9.9

Rectangle {
    id: root
    
    height: parent.height
    width: subroot.width+20
    color: "transparent"
    
    property Item navigator: parent.parent.parent.parent // Well this is awful
    property bool update: WifiManager.enabled && WifiManager.isOnline && parent.visible
    
    visible: false
    property string opkgState: AthenaOPKG.state
    property var upgradable: AthenaOPKG.upgradablePackages
    onUpgradableChanged: {
        if (upgradable) {
            visible = (upgradable.length > 0);
        }
    }
    onOpkgStateChanged: {
        if (upgradable) {
            visible = (upgradable.length > 0);
        }
    }
    onUpdateChanged: {
        if (update) {
            updateTimer.running = true;
        }
    }
    
    Item {
        id: subroot
        anchors.centerIn: parent
        height: parent.height*Constants.dimensions.navbar_icon_scale
        width: updateIcon.width
        Text {
            id: updateIcon
            
            anchors.centerIn: parent
            text: Icons.material.system_update
            font.pixelSize: parent.height*0.8
            font.family: Fonts.material.name
            color: "#000000"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: navigator.showSettings(99);
        }
    }
    Timer {
        id: updateTimer
        interval: 3600000
        repeat: true
        running: false
        triggeredOnStart: true
        onTriggered: {
            if (WifiManager.enabled && WifiManager.isOnline) {
                AthenaOPKG.update(0x05);
            } else {
                running = false;
            }
        }
    }
}
