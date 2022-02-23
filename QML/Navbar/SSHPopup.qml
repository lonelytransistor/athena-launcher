import QtQuick 2.6

import "." as N
import Athena 9.9

N.Popup {
    id: root
    
    contentHeight: sshList.height
    width: 600
    
    on: true
    onPressed: on=!on
    title: "Inhibit suspend\tSSH"
    icon: Icons.material.admin_panel_settings;

    Item {
        id: sshList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        
        property int margin: 10
        property int cellHeight: 72
        property var options: AthenaSystem.sshConnections

        height: options.length*(sshList.cellHeight+listView.spacing)
        
        onOptionsChanged: {
            listView.model.clear()
            for (var i=0; i<options.length; i++) {
                let pid_m = options[i].match(/([0-9]+):/);
                pid_m = pid_m.length>1 ? pid_m[1] : -1;
                listView.model.append({ix: i, label: options[i], pid: pid_m});
            }
        }
        Component {
            id: sshListDelegate
            Rectangle {
                width: listView.width
                height: sshList.cellHeight
                Rectangle {
                    id: iconItem
                    color: "#A0A0A0"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: sshList.margin
                    }
                    Text {
                        anchors.centerIn: parent
                        text: Icons.material.remove_circle_outline
                        font.family: Fonts.material.name
                        font.pixelSize: parent.height*0.35
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (pid != -1) {
                                AthenaSystem.kill(pid);
                            }
                        }
                    }
                }
                Text {
                    id: textItem
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: sshList.margin
                        right: iconItem.left
                        rightMargin: sshList.margin
                    }
                    text: label
                    font.pixelSize: parent.height*0.35
                }
            }
        }
        ListView {
            id: listView
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10
            model: ListModel {}
            interactive: false
            delegate: sshListDelegate
        }
    }
}