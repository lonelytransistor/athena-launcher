import QtQuick 2.0
import com.remarkable 1.0

import "." as N
import Athena 9.9

Rectangle {
    id: root
    
    height: parent.height
    width: subroot.width+20
    color: homePopup.visible ? "#A0A0A0" : "transparent"
    visible: WifiManager.isOnline
    
    Rectangle {
        id: homePopup
        border.width: 2
        border.color: "#000000"
        clip: true
        anchors {
            right: root.right
            bottom: root.top
        }
        visible: false
        width: homePopup_i.width
        height: homePopup_i.height
        N.HASSPopup {
            id: homePopup_i
        }
    }
    Item {
        id: subroot
        anchors.centerIn: parent
        height: parent.height*Constants.dimensions.navbar_icon_scale
        width: homeIcon.width
        Text {
            id: homeIcon
            
            anchors.centerIn: parent
            text: Icons.material["home"]
            font.pixelSize: parent.height*0.8
            font.family: Fonts.material.name
            color: "#000000"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: homePopup.visible=!homePopup.visible
        }
    }
}
