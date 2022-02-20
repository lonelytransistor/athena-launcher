import QtQuick 2.0
import com.remarkable 1.0

import "." as N
import Athena 9.9

Rectangle {
    id: root
    
    height: parent.height
    width: subroot.width+20
    color: wifiPopup.visible ? "#A0A0A0" : "transparent"

    readonly property string iconForSignalStrength: {
        if (!WifiManager.enabled) {
            return Icons.remarkable.icon_airplane
        } else if (!WifiManager.isOnline) {
            return Icons.remarkable.icon_wifi_off;
        }
        
        var sig = WifiManager.signalStrength;
        if (sig > -50) {
            return Icons.remarkable.icon_wifi_3;
        } else if (sig > -60) {
            return Icons.remarkable.icon_wifi_2;
        } else if (sig > -70) {
            return Icons.remarkable.icon_wifi_1;
        } else if (sig > -80) {
            return Icons.remarkable.icon_wifi_0;
        }
        return Icons.remarkable.icon_wifi_x;
    }

    N.WifiPopup {
        id: wifiPopup
    }
    Item {
        id: subroot
        anchors.centerIn: parent
        height: parent.height*Constants.dimensions.navbar_icon_scale
        width: wifiIcon.width
        
        Text {
            id: wifiIcon
            
            anchors.centerIn: parent
            text: root.iconForSignalStrength
            font.pixelSize: parent.height*0.8
            font.family: Fonts.icomoon.name
            color: "#000000"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: wifiPopup.visible=!wifiPopup.visible
        }
    }
}
