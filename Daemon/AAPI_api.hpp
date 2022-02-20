#ifndef __AAPI_API_H__
#define __AAPI_API_H__

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/sysinfo.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <fcntl.h>
#include <signal.h>
#include <iostream>
#include <thread>
#include <regex>
#include <dirent.h>
#include <errno.h>
#include <vector>
#include <string>
#include <sstream>
#include <iterator>
#include <functional>
#include <systemd/sd-bus.h>
#include "json.hpp"
#include "AAPI_uinput.hpp"
#include "processManager.hpp"

//#include <mosquitto.h>
#include "mosquitto.h"
using namespace nlohmann;

class AAPI {
private:
    sd_bus *m_dBus;
    mosquitto *m_mosquittoClient;
    uinput *m_uinput;
    ProcessManager *m_PM;
    std::map<std::string, std::string> m_globalSettingsCache;
    
    std::string BATTERY_DIR = "/sys/class/power_supply/";
    //std::string DRAFT_DIR = "/home/kat/Sources/RM2-kernel/Athena-kernel/xochitlPlugins/Launcher/tmp/";
    std::string DRAFT_DIR = "/opt/etc/draft/";
    std::string SETTINGS_DIR = "/etc/athena/"; //settings/
    std::string SETTINGS_GLOBAL = "global.store";
    std::string KMSG = "/dev/kmsg";
    template<class C> json JSON_SUCCESSFUL(C data) {
        json ret;
        ret["success"] = true;
        ret["data"] = data;
        return ret;
    }
    template<class C> json JSON_UNSUCCESSFUL(C data) {
        json ret;
        ret["success"] = false;
        ret["data"] = data;
        return ret;
    }
    json JSON_UNSUCCESSFUL() {
        return JSON_UNSUCCESSFUL<const char*>("Failure");
    }
    json JSON_SUCCESSFUL() {
        return JSON_SUCCESSFUL<const char*>("Success");
    }
    
    //ProcessManager
    json hook_launcher_key(int key, bool exclusive);
    json get_running_apps();
    json get_current_app();
    json get_launcher_app();
    json switch_to_app(std::string appName);
    json start_app(std::string appName, std::string appPath);
    json kill_app(std::string appName);
    json get_available_apps();
    json system_captureScreenshot(std::string path);
    //Settings
    json get_private_settings_store(std::string GUID);
    json set_private_settings_store(std::string GUID, json data);
    json get_global_settings_store(std::string GUID);
    json set_global_setting(std::string GUID, std::string var, std::string val);
    //Mosquitto
    json mosquitto_pub(std::string host, int port, std::string topic, std::string payload);
    //Kernel
    json send_uinput(uint16_t keycode, bool down);
    json send_vHID(uint16_t keycode, bool down);
public:
    std::string eval(std::string cmd, std::string GUID, std::string payload);    
    ~AAPI();
    AAPI(ProcessManager *pm);
};

#endif //__AAPI_API_H__
