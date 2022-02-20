import QtQuick 2.6
import QtQuick.Controls 2.4

import "." as L
import Athena 9.9

Rectangle {
    id: root
    color: "#FFFFFF"
    anchors.fill: parent
    clip: true
    
    L.JSONGridView {
        id: root_grid
        anchors {
            top: parent.top
            bottom: ram_bar.top
            left: parent.left
            right: parent.right
        }
        
        Component {
            id: iconDelegate
            Item {
                width: root_grid.cellWidth
                height: root_grid.cellHeight
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: Constants.dimensions.recentsItem_margin
                    anchors.bottomMargin: Constants.dimensions.recentsItem_margin
                    anchors.leftMargin: Constants.dimensions.recentsItem_margin
                    anchors.rightMargin: Constants.dimensions.recentsItem_margin
                    
                    color: "white"
                    border.width: 1
                    border.color: "black"
                    Rectangle {
                        id: recents_bar
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: Constants.dimensions.recentsBar_height
                        color: "#353535"
                        Rectangle {
                            id: recents_icon
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.topMargin: Constants.dimensions.recentsIcon_margin
                            anchors.bottomMargin: Constants.dimensions.recentsIcon_margin
                            anchors.leftMargin: Constants.dimensions.recentsIcon_margin
                            width: Constants.dimensions.recentsBar_height-Constants.dimensions.recentsIcon_margin*2
                            
                            color: "white"
                            border.width: 1
                            border.color: "black"
                            Image {
                                anchors.fill: parent
                                source: imgFile
                                asynchronous: true
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                            }
                        }
                        Text {
                            id: recents_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: recents_icon.right
                            anchors.right: parent.right
                            anchors.topMargin: Constants.dimensions.text_margin
                            anchors.bottomMargin: Constants.dimensions.text_margin
                            anchors.leftMargin: Constants.dimensions.text_margin+Constants.dimensions.icon_margin
                            anchors.rightMargin: Constants.dimensions.text_margin
                            text: name
                            elide: Text.ElideMiddle
                            font.pixelSize: Constants.dimensions.recentsBar_height/2
                            verticalAlignment: Text.AlignVCenter
                            color: "white"
                        }
                    }
                    Rectangle {
                        id: recents_thumbnail
                        anchors.top: recents_bar.bottom
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        
                        color: "white"
                        border.width: 1
                        border.color: "black"
                        Image {
                            anchors.fill: parent
                            anchors.topMargin: 2
                            anchors.bottomMargin: 2
                            anchors.leftMargin: 2
                            anchors.rightMargin: 2
                            asynchronous: true
                            source: launcher ? Libraries.api.SettingsPrivate.lockscreen.template_path : "/tmp/_"+name+".jpg"
                            mipmap: true
                        }
                    }
                    Rectangle {
                        id: recents_grayOverlay
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.5
                        visible: false
                    }
                    GestureArea {
                        onTap: {
                            if (launcher) {
                                setLauncherState();
                            } else {
                                recents_grayOverlay.visible = false;
                                prepareAppLaunch(name, desc, imgFile, function() {
                                    if (recents_grayOverlay.visible) {
                                        Libraries.api.startApp(name, call);
                                    } else {
                                        Libraries.api.switchApp(name);
                                    }
                                });
                            }
                        }
                        onDragRight: {
                            if (!launcher && !recents_grayOverlay.visible) {
                                recents_grayOverlay.visible = true;
                                Libraries.api.killApp(name);
                            }
                        }
                        onDragDown: root_grid.scrollUp()
                        onDragUp: root_grid.scrollDown()
                    }   
                }
            }
        }
        
        cellHeight: height/3
        cellWidth: cellHeight*3/4
        delegate: iconDelegate
        availableApps: []
        runningApps: []
        filter: true
    }
    L.RamBar {
        id: ram_bar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 72
        ramFree: 0
        ramTotal: 0
    }
    signal refresh()
    onRefresh: visibleChanged()
    
    Timer {
        id: root_delay
        interval: 5
        running: false
        onTriggered: {
            var running_buf = Libraries.api.runningApps;

            if (root_grid.runningApps_cache != JSON.stringify(running_buf)) {
                root_grid.availableApps = Libraries.api.availableApps;
                root_grid.runningApps = running_buf;
                root_grid.availableAppsChanged();
            }
        }
    }
    onVisibleChanged: {
        ram_bar.ramFree = Math.round(AthenaSystem.getFreeRAM()/1048576);
        ram_bar.ramTotal = Math.round(AthenaSystem.getTotalRAM()/1048576);
        if (visible) {
            root_delay.running = true;
        }
    }
}
