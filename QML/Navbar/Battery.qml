import QtQuick 2.6
import com.remarkable 1.0

import "." as N
import Athena 9.9

Rectangle {
    id: root
    
    height: parent.height
    width: subroot.width+20
    color: batteryPopup.visible ? "#A0A0A0" : "transparent"
    
    property bool batteryCharging: Libraries.battery.chargerState==1
    property int batteryLevel: Libraries.battery.percentage
    
    N.BatteryPopup {
        id: batteryPopup
    }
    Item {
        id: subroot
        anchors.centerIn: parent
        height: parent.height*Constants.dimensions.navbar_icon_scale
        width: batteryIcon.width
        Text {
            id: batteryIcon
            
            anchors.centerIn: parent
            text: Icons.remarkable.icon_battery_100
            font.pixelSize: parent.height*0.8
            font.family: Fonts.icomoon.name
            color: "#000000"
            
            Text {
                id: batteryText
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: parent.width*0.32

                visible: (root.batteryLevel>0 && root.batteryLevel<100)
                text: root.batteryLevel
                color: "#FFFFFF"
                font.pixelSize: parent.height*0.5
                font.family: Fonts.d7mono.name
            }
        }
        Rectangle {
            id: chargingIcon
            
            anchors {
                top: batteryIcon.bottom
                left: batteryIcon.left
                right: batteryIcon.right
            }
            color: "#000000"
            height: 5
            visible: batteryCharging
        }
        MouseArea {
            anchors.fill: parent
            onClicked: batteryPopup.visible=!batteryPopup.visible
        }
    }
}
