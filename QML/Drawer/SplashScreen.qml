import QtQuick 2.6
import QtQuick.Controls 2.4

Rectangle {
    id: root
    anchors.fill: parent
    color: "#FFFFFF"
    
    visible: false
    property string name: ""
    property string desc: ""
    property string imgFile: ""
    property var func: function(){}
    
    signal refresh()
    
    Text {
        id: loadText
        text: "Please wait..."
        anchors {
            bottom: parent.bottom
            right: parent.right
            bottomMargin: 32
            rightMargin: 32
        }
        font.pixelSize: 32
    }
    Image {
        id: iconImage
        source: imgFile
        anchors.centerIn: parent
        
        width: parent.width*0.25
        height: width
        sourceSize.width: width
        sourceSize.height: width
        fillMode: Image.PreserveAspectFit
        mipmap: true
    }
    Text {
        id: nameText
        text: name
        anchors {
            top: iconImage.bottom
            topMargin: 64
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width*0.5
        
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        elide: Text.ElideMiddle
        font.pixelSize: 128
    }
    Text {
        id: descText
        text: desc
        anchors {
            top: nameText.bottom
            topMargin: 24
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width*0.5
        
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        //elide: Text.ElideMiddle
        font.pixelSize: 32
    }
        

    Timer {
        id: splashTimer0
        interval: 1000
        onTriggered: {
            func();
            splashTimer1.running = true;
        }
    }
    Timer {
        id: splashTimer1
        interval: 100
        repeat: true
        onTriggered: {
            root.visible = false;
            refresh();
        }
    }
    onVisibleChanged: {
        if (root.visible) {
            splashTimer0.running = true;
        } else {
            splashTimer0.running = false;
        }
        splashTimer1.running = false;
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.visible = false;
            refresh();
        }
    }
}
