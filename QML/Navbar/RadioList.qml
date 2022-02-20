import QtQuick 2.6

import "." as N
import Athena 9.9

Item {
    id: root
    
    property int margin: 10
    property int cellHeight: 72
    property int checkedId: 0
    property var options: []
    signal changed()

    height: options.length*(root.cellHeight+radioView.spacing)
    
    onCheckedIdChanged: {
        changed()
    }
    onOptionsChanged: {
        radioView.model.clear()
        for (var i=0; i<options.length; i++) {
            radioView.model.append({ix: i, label: options[i]});
        }
    }
    Component {
        id: radioDelegate
        Rectangle {
            width: radioView.width
            height: root.cellHeight
            color: root.checkedId==ix?"#000000":"#FFFFFF"
            Text {
                id: iconItem
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: root.margin
                }
                text: root.checkedId==ix?Icons.material["radio_button_checked"]:Icons.material["radio_button_unchecked"]
                font.family: Fonts.material.name
                font.pixelSize: parent.height*0.35
                color: root.checkedId==ix?"#FFFFFF":"#000000"
            }
            Text {
                id: textItem
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: iconItem.right
                    leftMargin: parent.height*0.1
                    right: parent.right
                    rightMargin: root.margin
                }
                text: label
                font.pixelSize: parent.height*0.35
                color: root.checkedId==ix?"#FFFFFF":"#000000"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.checkedId = ix;
                }
            }
        }
    }
    ListView {
        id: radioView
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10
        model: ListModel {}
        interactive: false
        delegate: radioDelegate
    }
}
