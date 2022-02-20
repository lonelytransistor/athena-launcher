import QtQuick 2.6
import com.remarkable 1.0

import "." as N
import Athena 9.9

N.Popup {
    id: root
    
    contentHeight: wifiInfo.height
    width: 500
    
    on: WifiManager.enabled
    onPressed: WifiManager.toggleEnabled()
    title: "WiFi"
    icon: Icons.material.network_wifi
    
    property string macAddress: WifiManager.hardwareAddress
    property string networkName: WifiManager.currentSsid
    property int signalStrength: WifiManager.signalStrength
    property string ipAddress: {
        var ips = "";
        for (var i=0; i<WifiManager.ipAddresses.length; i++) {
            if (ips.length) {
                ips = ips + "\n";
            }
            ips = ips + WifiManager.ipAddresses[i];
        }
        return ips;
    }
    Column {
        id: wifiInfo
        spacing: 32
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            text: "Connected to:"
            color: "#000000"
            font.pixelSize: 32
        }
        Text {
            text: "SSID: " + root.networkName + "\nRSSI: " + root.signalStrength + "\nMAC: " + root.macAddress + "\nIP: " + root.ipAddress + "\nSSH pass: " + Settings.developerPassword
            color: "#000000"
            font.pixelSize: 26
        }
    }
}
