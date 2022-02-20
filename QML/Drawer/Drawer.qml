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
                    id: icon_rect
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Constants.dimensions.icon_margin
                    anchors.rightMargin: Constants.dimensions.icon_margin
                    anchors.topMargin: Constants.dimensions.icon_margin
                    width: root_grid.cellWidth-Constants.dimensions.icon_margin*2
                    height: root_grid.cellWidth-Constants.dimensions.icon_margin*2
                    clip: true
                    Item {
                        anchors.fill: parent
                        Image {
                            id: icon_image
                            source: imgFile
                            anchors.fill: parent
                            mipmap: true
                            asynchronous: true
                            sourceSize.width: width
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectFit
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                        }
                        Image {
                            id: icon_background
                            source: "../_common/roundedBorder.svg"
                            anchors.fill: parent
                            sourceSize.width: width
                            sourceSize.height: height
                        }
                        Rectangle {
                            id: icon_border
                            anchors.fill: parent
                            border.width: 1
                            border.color: "black"
                            radius: 35
                            color: "transparent"
                        }
                        Image {
                            id: icon_running
                            source: "../_common/running.svg"
                            anchors.top: parent.top
                            anchors.right: parent.right
                            width: parent.width*0.3
                            height: parent.height*0.3
                            visible: running
                            mipmap: true
                            sourceSize.width: width
                            sourceSize.height: height
                        }
                    }
                }
                Text {
                    id: icon_text
                    anchors.top: icon_rect.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Constants.dimensions.text_margin
                    anchors.rightMargin: Constants.dimensions.text_margin
                    anchors.bottomMargin: Constants.dimensions.text_margin
                    text: name
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideMiddle
                    font.pixelSize: Constants.dimensions.text_size
                    color: "black"
                }
                GestureArea {
                    onTap: {
                        if (launcher) {
                            setLauncherState();
                        } else {
                            prepareAppLaunch(name, desc, imgFile, function() {
                                Libraries.api.startApp(name, call);
                            });
                        }
                    }
                    onDragDown: root_grid.scrollUp()
                    onDragUp: root_grid.scrollDown()
                }
            }
        }
        
        cellWidth: Constants.dimensions.icon_size + Constants.dimensions.icon_margin*2
        cellHeight: Constants.dimensions.icon_size + Constants.dimensions.icon_margin*2 + Constants.dimensions.text_margin + Constants.dimensions.text_size*2
        delegate: iconDelegate
        availableApps: []
        runningApps: []
        filter: false
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
            var available_buf = Libraries.api.availableApps;
            
            if (root_grid.availableApps.length != available_buf.length) {
                root_grid.availableApps = available_buf;
                root_grid.runningApps = running_buf;
            } else if (root_grid.runningApps_cache != JSON.stringify(running_buf)) {
                root_grid.runningApps = running_buf;
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
