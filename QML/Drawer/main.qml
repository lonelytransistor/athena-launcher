import QtQuick 2.6
import QtQuick.Controls 2.4

import "." as L
import Athena 9.9

Item {
    id: root
    anchors.fill: parent
    
    states: [
        State {
            name: "drawer"
            PropertyChanges {
                target: drawer
                visible: true
            }
        },
        State {
            name: "recents"
            PropertyChanges {
                target: recents
                visible: true
            }
        }
    ]
    function setLauncherState(s) {
        if (s == "drawer") {
            state = "drawer";
        } else if (s == "recents") {
            state = "recents";
        } else {
            state = "";
        }
    }
    function prepareAppLaunch(name, desc, imgFile, cb) {
        Libraries.api.startLauncherKeyHook(Constants.keycodes.POWER, true);
        splashScreen.name = name;
        splashScreen.desc = desc;
        splashScreen.imgFile = imgFile;
        splashScreen.func = cb;
        splashScreen.visible = true;
    }
    
    Item {
        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
            bottom: parent.bottom
            bottomMargin: 72
        }
        Item {
            id: drawer
            visible: false
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
            }
            L.Drawer {
                id: drawer_o
            }
        }
        Item {
            id: recents
            visible: false
            anchors.fill: parent
            
            MouseArea {
                anchors.fill: parent
            }
            L.Recents {
                id: recents_o
            }
        }
    }
    L.SplashScreen {
        id: splashScreen
        onRefresh: {
            recents_o.refresh();
            drawer_o.refresh();
        }
    }
}
