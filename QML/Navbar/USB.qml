import QtQuick 2.0

import "." as N
import Athena 9.9

Rectangle {
    id: root
    
    height: parent.height
    width: subroot.width
    color: usbPopup.visible ? "#A0A0A0" : "transparent"
    
    property string usbMode: "charge"

    N.USBPopup {
        id: usbPopup
    }
    Item {
        id: subroot
        anchors.centerIn: parent
        height: parent.height*Constants.dimensions.navbar_icon_scale
        width: batteryIcon.width
        Text {
            id: batteryIcon
            
            anchors.centerIn: parent
            text: {
                if (root.usbMode == "camera") {
                    return Icons.material["photo_camera"];
                } else if (root.usbMode == "mtp") {
                    return Icons.material["save"];
                } else if (root.usbMode == "hid") {
                    return Icons.material["mouse"];
                } else if (root.usbMode == "acm") {
                    return Icons.material["adb"];
                } else if (root.usbMode == "charge") {
                    return Icons.material["power"];
                }
            }
            font.pixelSize: parent.height*0.8
            font.family: Fonts.material.name
            color: "#000000"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: usbPopup.visible=!usbPopup.visible
        }
    }
}
