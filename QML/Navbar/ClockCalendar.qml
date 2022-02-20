import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import "." as N
import Athena 9.9

Calendar {
    id: root
    anchors.fill: parent
    
    property int oldMonth: -1
    property var calendarData: []
    property var busyDates: []
    onCalendarDataChanged: refreshBusyDates(0)
    
    function refreshBusyDates(dir) {
        busyDates = [];
        var v_month = root.visibleMonth;
        if (dir==1) {
            v_month=(v_month+1)%12;
        } else if (dir==-1) {
            v_month=(v_month-1)%12;
        }
        for (var n=0; n<calendarData.length; n++) {
            var date = new Date(calendarData[n].start_date);
            var day = date.getDate();
            var month = date.getMonth();
            var year = date.getFullYear();
            if (v_month==month && root.visibleYear==year) {
                if (!busyDates.includes(day)) {
                    busyDates.push(day);
                }
            }
        }
        if (dir==1) {
            root.showNextMonth();
        } else if (dir==-1) {
            root.showPreviousMonth();
        } else {
            root.showNextMonth();
            root.showPreviousMonth();
        }
    }
    
    onClicked: function(date) {
        if (date.getMonth()!=oldMonth) {
            oldMonth = root.visibleMonth;
            refreshBusyDates();
        }
    }
    style: CalendarStyle {
        gridVisible: true
        
        dayDelegate: Rectangle {
            color: {
                if (styleData.selected)
                    return "#353535";
                if (styleData.visibleMonth && styleData.valid)
                    if (root.busyDates.includes(styleData.date.getDate()))
                        return "#A0A0A0"
                    else
                        return "#FFFFFF";
                return "#7F7F7F";
            }
            border.width: {
                var date = new Date;
                if (styleData.date.getDate() == date.getDate() &&
                    styleData.date.getMonth() == date.getMonth() &&
                    styleData.date.getYear() == date.getYear())
                    return 5;
                else
                    return 0;
            }
            border.color: {
                if (styleData.selected)
                    return "#A0A0A0";
                return "#000000";
            }
            Label {
                text: styleData.date.getDate()
                anchors.centerIn: parent
                font.pixelSize: parent.height*0.66
                font.family: d7Font.name
                color: {
                    if (styleData.selected)
                        return "#FFFFFF";
                    return "#000000";
                }
            }
        }
        dayOfWeekDelegate: Rectangle {
            color: "#353535"
            border.width: 0
            height: 0
        }
        navigationBar: Rectangle {
            height: root.height*0.15
            color: "#353535"

            Label {
                text: Libraries.utils.removeDiacritics(styleData.title)
                anchors.fill: parent
                anchors.topMargin: parent.height*0.17
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: parent.height*0.66
                font.family: d7Font.name
            }
            GestureArea {
                onDragRight: refreshBusyDates(-1)
                onDragLeft: refreshBusyDates(1)
            }
        }
    }
}
