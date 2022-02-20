#include "AAPI_api.hpp"
using namespace nlohmann;
//Helpers
AAPI::AAPI(ProcessManager *pm) {
    m_PM = pm;
    mosquitto_lib_init();
    if ((m_mosquittoClient = mosquitto_new(NULL, true, NULL)) == NULL)
        throw std::invalid_argument(std::string("Unable to init mosquitto: ") + strerror(errno));
    try {
        m_uinput = new uinput;
    } catch (std::exception& e) {
        std::cerr<<e.what()<<std::endl;
    }
}
AAPI::~AAPI() {
    if (m_mosquittoClient)
        mosquitto_destroy(m_mosquittoClient);
    mosquitto_lib_cleanup();
}
//

//ProcessManager
json AAPI::hook_launcher_key(int key, bool exclusive) {
    m_PM->declareLauncherHotkey(key, exclusive);
    return JSON_SUCCESSFUL();
}
json AAPI::get_running_apps() {
    json ret = json::array();
    for (std::string el : m_PM->getApps()) {
        ret.push_back(el);
    }
    return JSON_SUCCESSFUL(ret);
}
json AAPI::get_current_app() {
    return JSON_SUCCESSFUL(m_PM->getCurrentApp());
}
json AAPI::get_launcher_app() {
    return JSON_SUCCESSFUL(m_PM->getLauncherApp());
}
json AAPI::switch_to_app(std::string appName) {
    return m_PM->switchApp(appName) ? JSON_UNSUCCESSFUL(strerror(errno)) : JSON_SUCCESSFUL();
}
json AAPI::start_app(std::string appName, std::string appPath) {
    return m_PM->startApp(appName, appPath) ? JSON_UNSUCCESSFUL(strerror(errno)) : JSON_SUCCESSFUL();
}
json AAPI::kill_app(std::string appName) {
    return m_PM->killApp(appName) ? JSON_UNSUCCESSFUL(strerror(errno)) : JSON_SUCCESSFUL();
}
json AAPI::get_available_apps() {
    DIR* d_p;
    struct dirent *entry;
    json ret = json::array();

    if ((d_p = opendir(DRAFT_DIR.c_str())) == 0) {
        return JSON_UNSUCCESSFUL(strerror(errno));
    }
    while ((entry = readdir(d_p)) != NULL) {
        try {
            std::ifstream i(DRAFT_DIR + entry->d_name);
            std::string line;
            std::smatch smre;
            json el;
            while (std::getline(i, line)) {
                std::regex_search(line, smre, std::regex("(name|desc|call|term)\\s*=\\s*(.*)"));
                if (smre.size()) {
                    el[smre.str(1)] = smre.str(2);
                } else {
                    std::regex_search(line, smre, std::regex("(imgFile)\\s*=\\s*(.*)"));
                    if (smre.size()) {
                        el[smre.str(1)] = DRAFT_DIR + "icons/" + smre.str(2) + ".png";
                    }
                }
            }
            if (el.size()) {
                if (m_PM->getLauncherApp() == el["name"]) {
                    el["launcher"] = true;
                } else {
                    el["launcher"] = false;
                }
                if (m_PM->getCurrentApp() == el["name"]) {
                    el["active"] = true;
                } else {
                    el["active"] = false;
                }
                ret.push_back(el);
            }
        } catch (std::exception& e) {
            std::cout<<"Malformed file at: "<<(DRAFT_DIR + entry->d_name)<<std::endl;
        }
    }
    closedir(d_p);
    
    return JSON_SUCCESSFUL(ret);
}
//

//Settings
json AAPI::get_private_settings_store(std::string GUID) {
    json ret;
    try {
        std::ifstream i(SETTINGS_DIR + GUID);
        i >> ret;
    } catch (std::exception& e) {
        return JSON_UNSUCCESSFUL(e.what());
    }
    return JSON_SUCCESSFUL(ret);
}
json AAPI::set_private_settings_store(std::string GUID, json data) {
    try {
        std::ofstream o(SETTINGS_DIR + GUID);
        o << data;
    } catch (std::exception& e) {
        return JSON_UNSUCCESSFUL(e.what());
    }
    return JSON_SUCCESSFUL();
}
json AAPI::get_global_settings_store(std::string GUID) {
    if (!m_globalSettingsCache.size()) {
        std::ifstream i(SETTINGS_DIR + SETTINGS_GLOBAL);
        std::string line;
        std::smatch smre;
        while (std::getline(i, line)) {
            std::regex_search(line, smre, std::regex("(\\w+)\\s*=\\s*(.*)"));
            
            m_globalSettingsCache[smre.str(1)] = smre.str(2);
        }
    }
    return JSON_SUCCESSFUL(m_globalSettingsCache);
}
json AAPI::set_global_setting(std::string GUID, std::string var, std::string val) {
    if (!m_globalSettingsCache.size())
        get_global_settings_store(GUID);
    m_globalSettingsCache[var] = val;
    
    try {
        std::ofstream o(SETTINGS_DIR + SETTINGS_GLOBAL);
        
        for(std::map<std::string, std::string>::iterator it=m_globalSettingsCache.begin(); it!=m_globalSettingsCache.end(); ++it) {
            o<<it->first<<" = "<<it->second<<std::endl;
        }
    } catch (std::exception& e) {
        return JSON_UNSUCCESSFUL(e.what());
    }
    return JSON_SUCCESSFUL();
}
//

json AAPI::system_captureScreenshot(std::string path) {
    json ret;
    try {
        ret["path"] = path;
        ret["size"] = m_PM->saveFramebufferPNG(path);
    } catch (std::exception& e) {
        std::cerr<<"Cannot get screenshot"<<std::endl;
        return JSON_UNSUCCESSFUL(e.what());
    }
    return JSON_SUCCESSFUL(ret);
}
//

//Mosquitto
json AAPI::mosquitto_pub(std::string host, int port, std::string topic, std::string payload) {
    if (mosquitto_connect(m_mosquittoClient, host.c_str(), port, 60) != MOSQ_ERR_SUCCESS)
        return JSON_UNSUCCESSFUL(strerror(errno));
    int ret = mosquitto_publish(m_mosquittoClient, NULL, topic.c_str(), payload.size(), payload.c_str(), 0, false);
    mosquitto_disconnect(m_mosquittoClient);
    
    switch (ret) {
        case MOSQ_ERR_INVAL:
            return JSON_UNSUCCESSFUL("MOSQ_ERR_INVAL");
        case MOSQ_ERR_NOMEM:
            return JSON_UNSUCCESSFUL("MOSQ_ERR_NOMEM");
        case MOSQ_ERR_NO_CONN:
            return JSON_UNSUCCESSFUL("MOSQ_ERR_NO_CONN");
        case MOSQ_ERR_PROTOCOL:
            return JSON_UNSUCCESSFUL("MOSQ_ERR_PROTOCOL");
        case MOSQ_ERR_PAYLOAD_SIZE:
            return JSON_UNSUCCESSFUL("MOSQ_ERR_PAYLOAD_SIZE");
        case MOSQ_ERR_MALFORMED_UTF8:
            return JSON_UNSUCCESSFUL("MOSQ_ERR_MALFORMED_UTF8");
        case MOSQ_ERR_QOS_NOT_SUPPORTED:
            return JSON_UNSUCCESSFUL("MOSQ_ERR_QOS_NOT_SUPPORTED");
        case MOSQ_ERR_OVERSIZE_PACKET:
            return JSON_UNSUCCESSFUL("MOSQ_ERR_OVERSIZE_PACKET");
        case MOSQ_ERR_SUCCESS:
        default:
            return JSON_SUCCESSFUL();
    }
}
//

//Kernel
json AAPI::send_uinput(uint16_t keycode, bool down) {
    if (m_uinput)
        m_uinput->send(keycode, down);
    return JSON_SUCCESSFUL();
}
json AAPI::send_vHID(uint16_t keycode, bool down) {
    if (m_uinput)
        m_uinput->send(keycode, down);
    return JSON_SUCCESSFUL();
}
//

std::string AAPI::eval(std::string cmd, std::string GUID, std::string payload) {
    json ret;
    json payload_j = json::parse(payload);
    
    //ProcessManager
    if (cmd == "getRunningApps") {
        ret = get_running_apps();
    } else if (cmd == "getAvailableApps") {
        ret = get_available_apps();
    } else if (cmd == "getCurrentApp") {
        ret = get_current_app();
    } else if (cmd == "getLauncherApp") {
        ret = get_launcher_app();
    } else if (cmd == "switchApp") {
        ret = switch_to_app(payload_j["name"]);
    } else if (cmd == "startApp") {
        ret = start_app(payload_j["name"], payload_j["path"]);
    } else if (cmd == "killApp") {
        ret = kill_app(payload_j["name"]);
    } else if (cmd == "startLauncherKeyHook") {
        ret = hook_launcher_key(payload_j["keycode"], payload_j["exclusive"]);
    } else if (cmd == "captureScreenshot") {
        ret = system_captureScreenshot(payload_j["path"]);
    } else
    //Settings
           if (cmd == "getPrivateSettingsStore") {
        ret = get_private_settings_store(GUID);
    } else if (cmd == "setPrivateSettingsStore") {
        ret = set_private_settings_store(GUID, payload_j);
    } else if (cmd == "getGlobalSettingsStore") {
        ret = get_global_settings_store(GUID);
    } else if (cmd == "setGlobalSetting") {
        ret = set_global_setting(GUID, payload_j["variable"], payload_j["value"]);
    } else
    //Mosquitto
           if (cmd == "mosquitto") {
        ret = mosquitto_pub(payload_j["host"], payload_j["port"], payload_j["topic"], payload_j["message"]);
    } else
    //Kernel
           if (cmd == "uInputSend") {
        ret = send_uinput(payload_j["keycode"], payload_j["down"]);
    } else if (cmd == "vHIDSend") {
        ret = send_vHID(payload_j["keycode"].get<unsigned int>(), payload_j["down"].get<bool>());
    } else {
        ret = JSON_UNSUCCESSFUL("Malformed request");
    }
    return ret.dump();
}
