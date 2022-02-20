import QtQuick 2.6

import "." as N
import Athena 9.9

N.Popup {
    id: root
    
    contentHeight: 500
    width: subroot.width+60
    
    property string oldGovernor: ""
    on: AthenaSettings.cpuGovernor == "powersave"
    onPressed: {
        if (!on) {
            oldGovernor = AthenaSettings.cpuGovernor;
            AthenaSettings.cpuGovernor = "powersave";
        } else {
            AthenaSettings.cpuGovernor = oldGovernor ? oldGovernor : "ondemand";
        }
    }
    title: "Powersave"
    icon: Icons.material["battery_full"]
    
    onVisibleChanged: {
        if (visible) {
            root_delay.running = true;
        } else {
            root_delay.running = false;
        }
    }
    Item {
        Timer {
            id: root_delay
            interval: 5
            repeat: true
            running: false
            onTriggered: {
                interval = 20000;
                
                var vars = ["charge_full", "charge_now", "charge_full_design", "time_to_empty_now", "status",
                            "time_to_full_now", "voltage_now", "charge_counter", "cycle_count", "temp", "current_now"];
                var batt = AthenaSystem.getBatteries();
                for (var ix=0; ix<batt.length; ix++) {
                    for (var iy=0; iy<vars.length; iy++) {
                        subroot[vars[iy]] = (batt[ix][vars[iy]]==undefined)?0:batt[ix][vars[iy]];
                    }
                }
            }
        }
        
        id: subroot
        anchors.centerIn: parent
        width: batterySymbol.width + batteryInfo.width
        height: batterySymbol.height + batterySymbol_.height
        
        property int charge_full: 0
        property int charge_now: 0
        property int charge_full_design: 0
        property int time_to_empty_now: 0
        property int time_to_full_now: 0
        property int voltage_now: 0
        property int charge_counter: 0
        property int cycle_count: 0
        property int temp: 0
        property int current_now: 0
        property string status: ""
        property string charge_state: {
            if (status == "Discharging") {
                if (current_now > 0) {
                    return "Charging\n\t(invalid)Disconnected";
                } else {
                    return "Discharging\n\t\tDisconnected";
                }
            } else {
                if (current_now > 0) {
                    return "Charging\n\t\tConnected";
                } else {
                    return "Discharging\n(invalid)\tConnected";
                }
            }
        }
        Rectangle {
            id: batterySymbol
            
            border.width: 5
            border.color: "#000000"
            height: root.contentHeight*0.8
            width: height/4
            Rectangle {
                id: batteryCharge
                
                anchors {
                    left: parent.left
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 10
                    bottom: parent.bottom
                    bottomMargin: 10
                }
                height: (parent.height - 20)*(subroot.charge_now/subroot.charge_full_design)
                color: "#000000"
            }
            Rectangle {
                id: batteryDamage
                
                anchors {
                    left: parent.left
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 10
                    top: parent.top
                    topMargin: 10
                }
                height: (parent.height - 20)*(1-subroot.charge_full/subroot.charge_full_design)
                color: "#606060"
            }
        }
        Rectangle {
            id: batterySymbol_
            
            anchors {
                bottom: batterySymbol.top
                horizontalCenter: batterySymbol.horizontalCenter
                bottomMargin: -border.width
            }
            border.width: 5
            border.color: "#000000"
            width: batterySymbol.width/2
            height: width/2
        }
        Column {
            id: batteryInfo
            anchors {
                left: batterySymbol.right
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            property int fontSize: root.contentHeight/20
            
            Text {
                text: "Quality:    \t" + (Math.floor(subroot.charge_full/subroot.charge_full_design*10000)/100).toString() + "%"
                font.pixelSize: parent.fontSize
            }
            Text {
                text: "Voltage:    \t" + (Math.floor(subroot.voltage_now/1000)).toString() + "mV"
                font.pixelSize: parent.fontSize
            }
            Text {
                text: "Cycles:     \t" + subroot.cycle_count.toString()
                font.pixelSize: parent.fontSize
            }
            Text {
                text: "Charge left:\t" + (Math.floor(subroot.charge_now/subroot.charge_full*10000)/100).toString() + "%"
                font.pixelSize: parent.fontSize
            }
            Text {
                text: "Charge left:\t" + (Math.floor(subroot.charge_now/1000)).toString() + "mAh"
                font.pixelSize: parent.fontSize
            }
            Text {
                text: "Current:    \t" + (Math.floor(subroot.current_now/1000)).toString() + "mA"
                font.pixelSize: parent.fontSize
            }
            Text {
                text: "Temperature:\t" + (subroot.temp/10).toString() + "\xB0C"
                font.pixelSize: parent.fontSize
            }
            Text {
                text: "Status:\t" + subroot.charge_state
                font.pixelSize: parent.fontSize
            }
            Text {
                property int time: (subroot.time_to_empty_now == 0x59FFA)?subroot.time_to_full_now:subroot.time_to_empty_now
                property int timeH: Math.floor(time/3600)
                property int timeM: Math.floor(time/60)-timeH*60
                text: "Time left:  \t" + timeH.toString() + "h" + timeM.toString() + "min"
                font.pixelSize: parent.fontSize
            }
        }
    }
}
