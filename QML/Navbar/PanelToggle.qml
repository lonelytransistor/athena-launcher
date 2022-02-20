import QtQuick 2.6
import common 1.0
import device.ui.text 1.0
import device.ui.controls 1.0

import "." as N

N.Panel {
    id: root
    objectName: "PanelToggle"
    signal clicked
    signal pressed

    colorFront: Values.colorBlack
    colorBack: Values.colorWhite
    property bool on: false
    readonly property real size: Values.fontSizeH2 * Values.lineHeight
    rightInset: switchItem.visible ? switchItem.width + Values.designGridVerticalSpacing : 0

    MouseArea {
        anchors.fill: switchItem
        anchors.margins: -20
        onClicked: root.clicked()
        onPressed: root.pressed()
        z: -1 // make sure items managed by Panel.column will be clickable
    }

    Row {
        id: switchItem
        spacing: Values.designGridHorizontalGutter
        anchors.right: parent.right
        anchors.rightMargin: root.margin
        anchors.top: parent.top
        height: size
        visible: root.enabled

        TextParagraph {
            text: qsTr("Off")
            color: root.colorFront
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: switchSwitch
            width: size * 2
            height: size
            color: root.colorFront
            radius: width / 2

            Rectangle {
                x: root.on ? root.size * 1.1 : root.size * 0.1
                width: root.size * 0.8
                height: width
                radius: width / 2
                color: root.colorBack
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        TextParagraph {
            text: qsTr("On")
            color: root.colorFront
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
