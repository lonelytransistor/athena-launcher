import QtQuick 2.6
import QtQuick.Controls 2.4

import "." as N

Rectangle {
    id: root

    height: parent.height
    width: subroot.width+20
    color: calendarPopup.visible ? "#A0A0A0" : "transparent"
        
    property int hours: 0
    property string minutes: "00"
    property string day: "01"
    property string month: "01"
    property int year: 1900
    function timeChanged() {
        var date = new Date;
        hours = date.getHours();
        minutes = (date.getMinutes()<10?"0":"") + date.getMinutes();
        
        day = (date.getDate()<10?"0":"") + date.getDate();
        month = (date.getMonth()<9?"0":"") + (date.getMonth()+1);
        year = date.getFullYear();
    }
    Timer {
        interval: 60000
        running: parent.parent.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.timeChanged()
    }
    
    N.ClockPopup {
        id: calendarPopup
    }
    Item {
        id: subroot

        anchors.centerIn: parent
        width: dateText.width
        height: timeText.font.pixelSize + dateText.font.pixelSize + timeText.anchors.topMargin/2
        Text {
            id: timeText
            anchors {
                right: parent.right
                left: parent.left
                top: parent.top
            }
            font.pixelSize: root.height/2
            horizontalAlignment: Text.AlignHCenter
            
            text: root.hours + ":" + root.minutes
        }
        Text {
            id: dateText
            anchors {
                right: parent.right
                top: timeText.bottom
                topMargin: -font.pixelSize*0.2+timeText.anchors.topMargin/2
            }
            font.pixelSize: root.height/3
            horizontalAlignment: Text.AlignHCenter
            
            text: root.day + "." + root.month + "." + root.year
        }
        MouseArea {
            anchors.fill: parent
            onClicked: calendarPopup.visible=!calendarPopup.visible
        }
    }
}
