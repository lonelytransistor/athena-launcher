import QtQuick 2.6
import QtQuick.Controls 2.4

import "." as N
import Athena 9.9

Item {
    id: root
    height: parent.height
    width: parent.cellWidth
    property alias icon: textRoot.text
    property int keycode: 0
    property var func: ""
    property alias selected: selectionIndicator.visible
    
    Rectangle {
        id: selectionIndicator
        anchors.fill: parent
        anchors.topMargin: 2
        color: "#A0A0A0"
    }
    Text {
        id: textRoot
        anchors.fill: parent
        font.pixelSize: parent.height/2
        font.family: Fonts.material.name
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        
        text: Icons.material["grid_view"]
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.keycode) {
                Libraries.api.sendKeypress(root.keycode);
            } else if (root.func) {
                root.func();
            }
        }
    }
}
