import QtQuick 2.6
import QtQuick.Controls 2.4

Rectangle {
    id: root
    color: "#FFFFFF"
    border.width: 2
    border.color: "#000000"
    height: Values.navbar_height
    
    property int ramFree: 0
    property int ramTotal: 0
    
    Rectangle {
        id: root_free
        
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width*(root.ramTotal?(root.ramTotal-root.ramFree)/root.ramTotal:0)
        
        color: "#353535"
        border.width: 2
        border.color: "#000000"
        
        Text {
            anchors.centerIn: parent
            text: (root.ramTotal-root.ramFree) + "MB"
            font.pixelSize: parent.height*0.5
            color: "#FFFFFF"
        }
    }
    Item {
        id: root_full
        
        anchors {
            left: root_free.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        Text {
            anchors.centerIn: parent
            text: root.ramTotal + "MB"
            font.pixelSize: parent.height*0.5
        }
    }
}
