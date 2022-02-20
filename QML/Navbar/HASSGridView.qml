import QtQuick 2.6
import QtQuick.Controls 2.4

import "." as N
import Athena 9.9

GridView {
    id: root_grid
    anchors.fill: parent
    property var source: []
    
    property int lastDirScroll: -1
    
    onSourceChanged: {
        model.clear();
        for (var n=0; n<source.length; n++) {
            model.append(source[n]);
        }
    }

    model: ListModel{}
    snapMode: GridView.SnapOneRow
    focus: false
    interactive: false
    highlightMoveDuration: 0
    leftMargin: (width-Math.floor(width/cellWidth)*cellWidth)/2
    rightMargin: leftMargin
    
    signal tap(string message)
    
    Component {
        id: iconDelegate
        Item {
            width: root_grid.cellWidth
            height: root_grid.cellHeight

            Text {
                id: iconText
                
                anchors.centerIn: parent
                text: Icons.material.text_snippet;
                font.pixelSize: parent.height*0.6
                font.family: Fonts.material.name
                color: "#000000"
            }
            Text {
                id: nameText
                
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                text: name
                font.pixelSize: parent.height*0.1
                color: "#000000"
            }
            GestureArea {
                onTap: root_grid.tap(message)
                onDragLeft: {
                    if (root_grid.lastDirScroll == 1) {
                        root_grid.lastDirScroll = -1
                        root_grid.currentIndex = Math.max(root_grid.currentIndex-Math.floor(root_grid.width/root_grid.cellWidth)*Math.floor(root_grid.height/root_grid.cellHeight)*2+1, 0)
                    } else {
                        root_grid.currentIndex = Math.max(root_grid.currentIndex-Math.floor(root_grid.width/root_grid.cellWidth)*Math.floor(root_grid.height/root_grid.cellHeight), 0)
                    }
                }
                onDragRight: {
                    if (root_grid.lastDirScroll == -1) {
                        root_grid.lastDirScroll = 1
                        root_grid.currentIndex = Math.min(root_grid.currentIndex+Math.floor(root_grid.width/root_grid.cellWidth)*Math.floor(root_grid.height/root_grid.cellHeight)*2-1, root_grid.model.count-1)
                    } else {
                        root_grid.currentIndex = Math.min(root_grid.currentIndex+Math.floor(root_grid.width/root_grid.cellWidth)*Math.floor(root_grid.height/root_grid.cellHeight), root_grid.model.count-1)
                    }
                }
            }
        }
    }
    delegate: iconDelegate
}
