import QtQuick 2.6

import Athena 9.9

Item {
    id: root
    
    property int year: 2021
    property int month: 5
    property int day: 28
    
    function propagate() {
        var date = new Date;
        year = date.getFullYear();
        month = date.getMonth()+1;
        day = date.getDate();
        
        calendar.model.clear();
        var d = new Date(year, root.month-1, 1);
        var d_w = d.getDay()-1;
        if (d_w < 0)
            d_w = 6;
        if (d_w) {
            for (var i2=d_w; i2; i2--) {
                calendar.model.append({"c_date": d, "valid": false});
            }
        }
        for (var i=1; i<32; i++) {
            d = new Date(root.year, root.month-1, i);
            if (d.getMonth() == root.month-1) {
                calendar.model.append({"c_date": d, "valid": true});
            } else {
                break;
            }
        }
    }
    
    height: Math.ceil(calendar.model.count/7)*calendar.cellHeight
    Component {
        id: calendarDelegate
        Item {
            width: calendar.cellWidth
            height: calendar.cellHeight
            visible: valid
            Rectangle {
                anchors.fill: parent
                color: (c_date.getDay()==0||c_date.getDay()==6) ? "#80A0A0A0":"#80FFFFFF"
                radius: width*0.1
                border.width: (c_date.getDate()==root.day) ? 10 : 1
                border.color: (c_date.getDate()==root.day) ? "#A0000000" : "#50000000"
                TextShadow {
                    text: c_date.getDate()
                    anchors.centerIn: parent
                    font.pixelSize: parent.height*0.4
                }
            }
        }
    }
    GridView {
        id: calendar
        anchors.fill: parent
        cellWidth: parent.width/7.1
        cellHeight: cellWidth
        interactive: false

        model: ListModel {}
        delegate: calendarDelegate
    }
    onVisibleChanged: propagate();
}
