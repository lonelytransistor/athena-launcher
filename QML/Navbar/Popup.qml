import QtQuick 2.6

import "." as N
import Athena 9.9

Rectangle {
    id: root

    readonly property real headerHeight: 36//Values.fontSizeH2 * Values.lineHeight
    readonly property int margin: 16//Values.navigatorSettingsItemMargin
    height: contentHeight+headerHeight+margin*4
    property int contentHeight: 0

    signal pressed()
    property bool checkButton: true
    property bool on: false
    property string title: ""
    property string icon: ""
    
    visible: false
    border.width: 2
    border.color: "#000000"
    default property alias contents: childItem.children

    property double x_root: -parent.parent.x-parent.x
    property double y_root: height-parent.y-parent.parent.y-parent.parent.parent.y-parent.parent.parent.parent.y
    property double w_root: AthenaHook.rootItem.width
    property double h_root: height-y_root
    anchors.bottom: parent.top
    x: x_root + Math.max(0, Math.min(-x_root-width/2+parent.width/2, w_root-width))

    Rectangle {
        color: "#000000"
        opacity: 0.1
        x: x_root-root.x
        y: y_root
        width: w_root
        height: h_root
        z: -1
        MouseArea {
            anchors.fill: parent
            onClicked: root.visible = false;
        }
    }
    Item {
        id: titleItem
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: switchItem.height+margin*2
        
        MouseArea {
            anchors.fill: switchItem
            onPressed: root.pressed()
            visible: root.checkButton
        }
        Row {
            id: switchItem
            visible: root.checkButton
            anchors {
                left: parent.left
                leftMargin: margin
                top: parent.top
                topMargin: margin
            }
            height: headerHeight

            spacing: 10//Values.designGridHorizontalGutter

            Text {
                text: "Off"
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: switchItem.height*0.6
            }
            Rectangle {
                id: switchSwitch
                width: switchItem.height*2
                height: switchItem.height
                color: "#000000"
                radius: width / 2

                Rectangle {
                    x: root.on ? switchItem.height*1.1 : switchItem.height*0.1
                    width: switchItem.height * 0.8
                    height: width
                    radius: width / 2
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "On"
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: switchItem.height*0.6
            }
        }
        Text {
            text: root.title
            anchors {
                left: switchItem.right
                leftMargin: margin
                right: iconItem.right
                rightMargin: margin
                verticalCenter: switchItem.verticalCenter
            }
            font.pixelSize: switchItem.height*0.9
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            id: iconItem
            anchors {
                right: parent.right
                rightMargin: margin
                verticalCenter: switchItem.verticalCenter
            }
            text: icon
            font.pixelSize: parent.height*0.8
            font.family: Fonts.material.name
        }
        Rectangle {
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            height: 1
            color: "#000000"
        }
    }
    Item {
        id: childItem
        anchors {
            top: titleItem.bottom
            topMargin: margin
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: margin
        }
        MouseArea {
            anchors.fill: parent
        }
    }
}
