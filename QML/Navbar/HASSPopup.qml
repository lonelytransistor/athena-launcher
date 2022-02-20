import QtQuick 2.0

import "." as N
import Athena 9.9

N.HASSGridView {
    id: root
    height: 300
    width: 900
    
    cellHeight: height
    cellWidth: height
    source: Libraries.api.SettingsPrivate.mosquitto.messages
    onTap: Libraries.api.mosquitto_pub(message)
}
