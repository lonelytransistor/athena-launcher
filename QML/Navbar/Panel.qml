import QtQuick 2.6
import common 1.0
import device.ui.text 1.0

Item {
    id: panel
    objectName: "Panel"

    property var colorFront: Values.colorWhite
    property var colorBack: Values.colorBlack
    property string icon: ""
    property string header: ""
    property string text: ""
    property int rightInset: 0
    property int margin: Values.navigatorSettingsItemMargin
    property int padding: 0
    property alias column: column
    property var textModel: []
    property bool showFrame: false
    property alias elideTitle: titleText.elideTitle

    height: Math.max(column.height + Values.navigatorMargin + padding, Values.navigatorSidebarItemHeight)
    width: parent.width

    states: State {
        when: panel.showFrame || panel.icon.length > 0

        AnchorChanges {
            target: _textItem
            anchors.left: column.left
        }
    }

    Column {
        id: column
        spacing: showFrame ? 50 : 20
        width: parent.width
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            rightMargin: panel.margin + rightInset
            leftMargin: panel.margin
        }

        IconTitle {
            id: titleText
            icon: panel.icon
            title: panel.header
            color: root.colorFront
            rowSpacing: Values.designGridVerticalSpacing
            maxWidth: parent.width
        }

        TextParagraphSmall {
            id: _textItem
            width: parent.width
            text: panel.text
            lineHeight: Values.lineHeight
            color: root.colorFront
            visible: panel.text.length > 0
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            anchors.leftMargin: showFrame ? 20 : titleText.iconSize + titleText.rowSpacing
        }

        Repeater {
            model: textModel
            TextParagraph {
                text: textModel[index].text
                width: parent.width
                lineHeight: Values.lineHeight
                color: root.colorFront
                visible: text.length > 0
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }
    }
}
