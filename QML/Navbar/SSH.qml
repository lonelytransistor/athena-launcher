import QtQuick 2.0
import com.remarkable 1.0

import "." as N
import Athena 9.9

Rectangle {
    id: root
    
    height: parent.height
    width: subroot.width+20
    color: sshPopup.visible ? "#A0A0A0" : "transparent"
    
    visible: AthenaSystem.sshConnections.length>0
    property int idleSuspendDelay_old: Settings.idleSuspendDelay
    property int powerOffDelay_old: Settings.powerOffDelay
    onVisibleChanged: {
        if (visible && sshPopup.on) {
            idleSuspendDelay_old = Settings.idleSuspendDelay+0;
            powerOffDelay_old = Settings.powerOffDelay+0;
            Settings.idleSuspendDelay = 0;
            Settings.powerOffDelay = 0;
        } else {
            Settings.idleSuspendDelay = idleSuspendDelay_old;
            Settings.powerOffDelay = powerOffDelay_old;
        }
    }

    N.SSHPopup {
        id: sshPopup
        onOnChanged: root.visibleChanged();
    }
    Item {
        id: subroot
        anchors.centerIn: parent
        height: parent.height*Constants.dimensions.navbar_icon_scale
        width: wifiIcon.width
        
        Text {
            id: wifiIcon
            
            anchors.centerIn: parent
            text: Icons.material.admin_panel_settings
            font.pixelSize: parent.height*0.8
            font.family: Fonts.material.name
            color: "#000000"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: sshPopup.visible=!sshPopup.visible
        }
    }
}
