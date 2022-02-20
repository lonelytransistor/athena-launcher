import QtQuick 2.6
import QtQuick.Controls 2.4
import com.remarkable 1.0
import device.ui.controls 1.0
import device.ui.text 1.0
import device.view.dialogs 1.0

import "." as N
import Athena 9.9

Rectangle {
    id: root
    
    property var hookedObjects: {}
    
    Timer {
        id: ticker_60s
        interval: 60000
        triggeredOnStart: false
        repeat: true
        running: true
        property var func: {}
        
        onTriggered: {
            if (Libraries.api.SettingsPrivate.__obj_legacy_caller) {
                func = Libraries.api.SettingsPrivate.__obj_legacy_caller;
                delete Libraries.api.SettingsPrivate.__obj_legacy_caller;
            } else {
                if (!func) {
                    running = false;
                } else {
                    func();
                }
            }
        }
    }
    
    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }
    border.width: 2
    border.color: "#000000"
    height: Constants.remarkable.navigatorStatusbarHeight
    
    MouseArea {
        anchors.fill: parent
    }
    
    Row {
        id: notificationTray
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            right: navButtons.left
        }
        layoutDirection: Qt.LeftToRight
        spacing: 10
        
        N.Update {
        }
        N.HASS {
        }
    }
    Row {
        id: navButtons
        anchors.centerIn: parent
        height: parent.height
        width: parent.width/3
        property int cellWidth: width/children.length
        layoutDirection: Libraries.api.SettingsPrivate.LTR? Qt.LeftToRight : Qt.RightToLeft
        
        N.NavbarButton {
            id: recents_btn
            icon: Icons.material["grid_view"]
            //keycode: C.KEY.F2
            selected: false
            func: function() {
                if (hookedObjects["AthenaLauncher/Drawer"].obj.state == "recents") {
                    hookedObjects["AthenaLauncher/Drawer"].obj.setLauncherState();
                    recents_btn.selected = false;
                } else {
                    hookedObjects["AthenaLauncher/Drawer"].obj.setLauncherState("recents");
                    recents_btn.selected = true;
                }
                home_btn.selected = false;
            }
        }
        N.NavbarButton {
            id: home_btn
            icon: Icons.material["radio_button_unchecked"]
            //keycode: C.KEY.HOME
            selected: false
            func: function() {
                if (hookedObjects["AthenaLauncher/Drawer"].obj.state == "drawer") {
                    hookedObjects["AthenaLauncher/Drawer"].obj.setLauncherState();
                    home_btn.selected = false;
                } else {
                    hookedObjects["AthenaLauncher/Drawer"].obj.setLauncherState("drawer");
                    home_btn.selected = true;
                }
                recents_btn.selected = false;
            }
        }
        Item {}
        /*N.NavbarButton {
            id: back_btn
            icon: Icons.material["chevron_left"]
            //keycode: C.KEY.ESC
            func: function() {
                AthenaHook.screenshot("/home/root/.xochitlPlugins/AthenaLauncher/1.png")
            }
        }*/
    }
    Row {
        id: systemTray
        anchors {
            right: clock.left
            top: parent.top
            bottom: parent.bottom
            left: navButtons.right
        }
        layoutDirection: Qt.RightToLeft
        spacing: 10
        
        N.Battery {}
        N.Wifi {}
        N.USB {}
    }
    N.Clock {
        id: clock
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
    }
}
