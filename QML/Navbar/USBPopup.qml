import QtQuick 2.6

import "." as N
import Athena 9.9

N.Popup {
    id: root
    
    contentHeight: usbMode.height
    width: 600
    
    on: false
    onPressed: on=!on
    title: "USB gadget"
    icon: Icons.material["usb"];
        
    N.RadioList {
        id: usbMode
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        options: AthenaSettings.usbModes
        onChanged: {
            AthenaSettings.usbMode = AthenaSettings.usbModes[checkedId]
        }
    }
}
