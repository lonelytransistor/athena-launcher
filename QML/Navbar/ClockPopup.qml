import QtQuick 2.6

import "." as N
import Athena 9.9

N.Popup {
    id: root
    
    contentHeight: calendarObj.height
    width: 600
    
    checkButton: false
    title: "Calendar"
    icon: Icons.material["calendar_today"]

    N.Calendar {
        id: calendarObj
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }
}
