#include "processManager.hpp"

//Helpers
ProcessManager::ProcessManager() {
    struct fb_fix_screeninfo fixedFBInfo;
    struct fb_var_screeninfo variableFBInfo;
    if ((m_fb_fd = open(FB_NAME, O_RDWR)) < 0)
        throw std::invalid_argument(std::string("Unable to open FB: ") + strerror(errno));
    if (ioctl(m_fb_fd, FBIOGET_FSCREENINFO, &fixedFBInfo) < 0)
        throw std::invalid_argument(std::string("Unable to ioctl FB: ") + strerror(errno));
    if (ioctl(m_fb_fd, FBIOGET_VSCREENINFO, &variableFBInfo) < 0)
        throw std::runtime_error(std::string("Unable to ioctl FB: ") + strerror(errno));
    m_fb_sz = fixedFBInfo.smem_len;
    m_fb_width = variableFBInfo.xres;
    m_fb_height = variableFBInfo.yres;
    m_fb_buf = new char[m_fb_sz];
    if ((m_fb = mmap(NULL, m_fb_sz, PROT_READ|PROT_WRITE, MAP_SHARED, m_fb_fd, 0)) <= 0)
        throw std::invalid_argument(std::string("Unable to mmap FB: ") + strerror(errno));
    
    if (startLauncher())
        throw std::invalid_argument("Launcher unavailable");
}
ProcessManager::~ProcessManager() {
    for (std::map<std::string, ProcessDescription>::iterator it=m_runningApps.begin(); it!=m_runningApps.end(); ++it) {
        killApp(it->first);
    }

    munmap(m_fb, 0);
    close(m_fb_fd);
    delete m_fb_buf;
}
//

//Key hook
#define IS_HOTKEY_KEY(event) ((event.code == m_hook_pwrbtn))
#define IS_HOTKEY_UP(event) ((event.code == m_hook_pwrbtn) && (event.type == EV_KEY) && (event.value == 0))
void ProcessManager::grabExclusiveKbdHook(int fd, bool grab) {
    if (m_hook_exclusive) {
        if (ioctl(fd, EVIOCGRAB, grab?1:0) < 0) {
            std::cout<<"Exclusive keyboard hook "<<(grab?"un":"")<<"grab failed!"<<std::endl;
        }
    }
}
void ProcessManager::clearEventQueue(int fd) {
    fd_set set;
    FD_ZERO(&set);
    FD_SET(fd, &set);
    timeval timeout = {0, 200000};
    input_event event;
    while (select(fd+1, &set, NULL, NULL, &timeout) > 0) {
        read(fd, &event, sizeof(struct input_event));
        timeout.tv_sec = 0;
        timeout.tv_usec = 200000;
    }
}
void ProcessManager::forwardExclusiveKbdEvent(int fd, std::vector<input_event> eventQueue) {
    grabExclusiveKbdHook(fd, false);
    for (auto event : eventQueue) {
        write(fd, &event, sizeof(struct input_event));
    }
    clearEventQueue(fd);
    grabExclusiveKbdHook(fd, true);
    std::cout<<"Forwarded "<<eventQueue.size()<<" keyboard events: "<<std::endl;
}
void ProcessManager::BTNHookThread() {
    fd_set set;
    timeval timeout = {0, 500000};
    std::vector<input_event> eventQueue;
    time_t firstEvent_timestamp = 0;
    //
    int fd = open(PWRBTN_DEV.c_str(), O_RDWR);
    if (fd == -1) {
        std::cout<<"Cannot initialize keyboard hook!"<<std::endl;
        return;
    }
    grabExclusiveKbdHook(fd, true);
    
    struct input_event event;
    while (m_hook_pwrbtn) {
        // If already awaiting a second press, wait for a new event but allow timeout to allow event forwarding
        if (firstEvent_timestamp) {
            FD_ZERO(&set);
            FD_SET(fd, &set);
            // If timed-out then reset the timer and forward the event
            timeout.tv_sec = 0;
            timeout.tv_usec = 500000;
            if (select(fd+1, &set, NULL, NULL, &timeout) == 0) {
                firstEvent_timestamp = 0;
                eventQueue.push_back(event);
                forwardExclusiveKbdEvent(fd, eventQueue);
                eventQueue.clear();
                continue;
            }
        }
        read(fd, &event, sizeof(struct input_event));
        
        if (IS_HOTKEY_KEY(event)) {
            // If the keypress was a second hotkey up within the 1s window, then switchApp
            // If the window was missed, forward the event and reset the timer
            // If this is the first event, start the timer and await another event or a timeout
            if (IS_HOTKEY_UP(event)) {
                if (firstEvent_timestamp) {
                    if (time(NULL)-firstEvent_timestamp <= 1) {
                        eventQueue.clear();
                        clearEventQueue(fd);
                        switchApp(m_launcherApp);
                        break;
                    } else {
                        firstEvent_timestamp = 0;
                        eventQueue.push_back(event);
                        forwardExclusiveKbdEvent(fd, eventQueue);
                        eventQueue.clear();
                    }
                } else {
                    firstEvent_timestamp = time(NULL);
                    eventQueue.push_back(event);
                }
            } else {
                if (firstEvent_timestamp && (time(NULL)-firstEvent_timestamp > 1)) {
                    firstEvent_timestamp = 0;
                    eventQueue.push_back(event);
                    forwardExclusiveKbdEvent(fd, eventQueue);
                    eventQueue.clear();
                } else {
                    eventQueue.push_back(event);
                }
            }
        } else {
            if (event.code) {
                // If a different key is pressed, reset the timer and forward the event
                eventQueue.clear();
                firstEvent_timestamp = 0;
                eventQueue.push_back(event);
                forwardExclusiveKbdEvent(fd, eventQueue);
                eventQueue.clear();
            }
        }
    }
    grabExclusiveKbdHook(fd, false);
    close(fd);
}
void ProcessManager::declareLauncherHotkey(int key, bool exclusive_hook) {
    m_hook_pwrbtn = key;
    m_hook_exclusive = exclusive_hook;
    m_hook_thread = new std::thread([this](){
        this->BTNHookThread();
    });
}
//

//Framebuffer
void ProcessManager::restoreFramebuffer(std::string path) {
    try {
        std::streampos fsize = 0;
        std::ifstream input(path, std::ios::binary|std::ios::in);
        fsize = input.tellg();
        input.seekg(0, input.end);
        fsize = input.tellg() - fsize;
        if (input.tellg() != m_fb_sz) {
            throw std::invalid_argument("Wrong size.");
        }
        input.seekg(0, input.beg);
        input.read(m_fb_buf, m_fb_sz);
        
        // Copy the framebuffer
        memcpy(m_fb, m_fb_buf, m_fb_sz);
        // Update the framebuffer
        mxcfb_rect update_rect;
        update_rect.top = 0;
        update_rect.left = 0;
        update_rect.width = m_fb_width;
        update_rect.height = m_fb_height;
        mxcfb_update_data update_data;
        update_data.update_marker = 0;
        update_data.update_region = update_rect;
        update_data.waveform_mode = WAVEFORM_MODE_GC4;
        update_data.update_mode = UPDATE_MODE_FULL;
        update_data.dither_mode = EPDC_FLAG_EXP1;
        update_data.temp = TEMP_USE_REMARKABLE_DRAW;
        update_data.flags = 0;
        ioctl(m_fb_fd, MXCFB_SEND_UPDATE, &update_data);
    } catch (std::exception& e) {
        std::cerr<<"Couldn't restore framebuffer: "<<e.what()<<std::endl;
    }
}
void ProcessManager::saveFramebufferRAW(std::string path) {
    memcpy(m_fb_buf, m_fb, m_fb_sz);

    std::ofstream output(path, std::ios::binary|std::ios::out);
    output.write(m_fb_buf, m_fb_sz);
}
int ProcessManager::saveFramebufferPNG(std::string path) {
    for (uint32_t i=0; i<m_fb_sz/2; i+=1) {
        m_fb_buf[i] = ((uint16_t*)m_fb)[i]>>8;
    }
    
    png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!png_ptr) {
        throw std::invalid_argument("Unable to create a PNG structure.");
    }
    png_infop info_ptr = png_create_info_struct(png_ptr);
    if (!info_ptr) {
        png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
        throw std::invalid_argument("Unable to create a PNG info structure.");
    }
    FILE *fp = fopen(path.c_str(), "wb");
    if (setjmp(png_jmpbuf(png_ptr))) {
        png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
        fclose(fp);
        throw std::invalid_argument("Unable to execute libpng16.");
    }
    png_init_io(png_ptr, fp);
    png_set_IHDR(png_ptr, info_ptr, m_fb_width, m_fb_height, 8, PNG_COLOR_TYPE_GRAY, PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
    png_write_info(png_ptr, info_ptr);
    for (uint32_t i=0; i<m_fb_height; i++) {
        png_write_row(png_ptr, (png_const_bytep)&m_fb_buf[i*m_fb_width]);
    }
    png_write_end(png_ptr, NULL);

    int pos = ftell(fp);
    fclose(fp);
    return pos;
}
//

//
void ProcessManager::eraseApp(std::string appName) {
    std::unique_lock<std::mutex> lock(m_mutex);
    remove(m_runningApps[appName].thumbnail.c_str());
    remove(m_runningApps[appName].thumbnailPNG.c_str());
    m_runningApps.erase(appName);
}
void ProcessManager::destroyApp(std::string appName) {
    eraseApp(appName);
    if (appName == m_launcherApp) {
        std::cerr<<"Launcher exited. Restarting."<<std::endl;
        sleep(1);
        startLauncher();
    } else if (m_currentApp == appName) {
        std::cerr<<"App exited, switching to launcher."<<std::endl;
        m_currentApp = "";
        switchApp(m_launcherApp);
    }
}
int ProcessManager::startLauncher() {
    pid_t xochitl_pid = 0;
    try {
        std::string xochitl_pid_s;
        std::ifstream input(TMP_XOCHITL_PID, std::ios::in);
        getline(input, xochitl_pid_s);
        xochitl_pid = std::stoi(xochitl_pid_s);
    } catch (std::exception& e) {
        std::cout<<"INFO: Fresh boot."<<std::endl;
    }
    m_currentApp = "";
    m_launcherApp = "xochitl";
    return startApp("xochitl", "/usr/bin/xochitl", false, xochitl_pid);
}
std::vector<std::string> ProcessManager::getApps() {
    std::unique_lock<std::mutex> lock(m_mutex);
    
    std::vector<std::string> apps;
    for(std::map<std::string, ProcessDescription>::iterator it=m_runningApps.begin(); it!=m_runningApps.end(); ++it) {
        apps.push_back(it->first);
    }
    return apps;
}
int ProcessManager::killApp(std::string appName) {
    std::unique_lock<std::mutex> lock(m_mutex);

    if (m_launcherApp == appName) {
        std::cout<<"Refusing to kill a launcher"<<std::endl;
        return 0;
    }
    if (m_runningApps.find(appName) == m_runningApps.end())
        return ESRCH;
    pid_t pid = m_runningApps[appName].pid;
    m_runningApps[appName].killer = new std::thread([this, pid, appName](){
        int status;
        uint16_t n=2000;
        std::cout<<"Killing "<<appName<<std::endl;
        kill(pid, SIGKILL);
        kill(pid, SIGCONT);
        while ((waitpid(pid, &status, WNOHANG) != -1) && (n--)) {
            usleep(1);
        }
        if (!n) {
            kill(pid, SIGTERM);
        }
        this->destroyApp(appName);
    });
    return 0;
}
int ProcessManager::switchApp(std::string appName) {
    std::unique_lock<std::mutex> lock(m_mutex);

    if (m_currentApp == appName) {
        std::cout<<"Switching inhibited, app already open"<<std::endl;
        return 0;
    }
    if (m_runningApps.find(appName) == m_runningApps.end())
        return ESRCH;
    if (m_currentApp != "") {
        if (m_runningApps.find(m_currentApp) == m_runningApps.end())
            return ESRCH;
        if (kill(m_runningApps[m_currentApp].pid, SIGSTOP)) {
            std::cout<<std::string("Suspend failed! ")<<m_runningApps[m_currentApp].pid<<std::string(":")<<strerror(errno)<<std::endl;
        }
        saveFramebufferRAW(m_runningApps[m_currentApp].thumbnail);
        saveFramebufferPNG(m_runningApps[m_currentApp].thumbnailPNG);
        restoreFramebuffer(m_runningApps[appName].thumbnail);
        std::cout<<"Switching away from "<<m_runningApps[m_currentApp].name;
    } else {
        std::cout<<"Switching";
    }
    if (!kill(m_runningApps[appName].pid, SIGCONT)) {
        m_currentApp = appName;
        std::cout<<" to "<<m_currentApp<<std::endl;
    } else {
        std::cout<<std::string(" failed with PID:")<<m_runningApps[appName].pid<<std::string(":")<<strerror(errno)<<std::endl;
        return EBUSY;
    }
    if (m_currentApp == m_launcherApp) {
        m_hook_pwrbtn = 0;
    }
    return 0;
}
bool ProcessManager::isAppRunning(std::string appName) {
    std::unique_lock<std::mutex> lock(m_mutex);
    
    for(std::map<std::string, ProcessDescription>::iterator it=m_runningApps.begin(); it!=m_runningApps.end(); ++it) {
        if (it->first == appName) {
            return true;
        }
    }
    return false;
}
void ProcessManager::validateFork(ProcessDescription& pd) {
    std::unique_lock<std::mutex> lock(m_mutex);
    int status = 0;
    while (!waitpid(-pd.pid, &status, WSTOPPED)) {
        if (WIFSTOPPED(status))
            break;
        usleep(1);
    }
    m_runningApps[pd.name] = pd;
}
int ProcessManager::startApp(std::string appName, std::string appPath, bool isLauncher, pid_t pid) {
    if (isAppRunning(appName)) {
        return switchApp(appName);
    }
    
    ProcessDescription pd;
    if ((pid > 0) && (pid != getpid()) && (kill(pid, 0) != -1)) {
        pd.pid = pid;
        kill(pd.pid, SIGSTOP);
    } else if ((pd.pid = -fork()) == 0) {
        if (setpgid(0, 0)) {
            std::cerr<<"Fatal error!"<<strerror(errno)<<std::endl;
        }
        kill(getpid(), SIGSTOP);
        std::cout<<"Resumed"<<std::endl;
        if (isLauncher) {
            /*const char *envp[] = {"PATH=/bin:/sbin/:/usr/bin:/usr/sbin",
                                  "LD_PRELOAD=/opt/lib/librm2fb_client.so:/usr/lib/libAthenaXochitl.so",
                                  "TZ=Europe/Berlin",
                                  NULL};
            execl(appPath.c_str(), "", NULL, envp);*/
        } else {
            const char *envp[] = {"PATH=/bin:/sbin/:/usr/bin:/usr/sbin:/opt/bin:/opt/sbin:/opt/usr/bin:/opt/usr/sbin",
                                  "LD_PRELOAD=/opt/lib/librm2fb_client.so",
                                  "TZ=Europe/Berlin",
                                  NULL};
            execle(appPath.c_str(), "", NULL, envp);
        }
        exit(1);
    }
    pd.name = appName;
    pd.thumbnail = "/tmp/_";
    pd.thumbnail += appName;
    pd.thumbnailPNG = pd.thumbnail;
    pd.thumbnailPNG += ".png";
    pd.path = appPath;
    pd.running = true;
    pd.watchdog = new std::thread([this, pd](){
        std::string name = pd.name;
        int pid = pd.pid;
        std::cout<<"[watchdog]{"<<std::this_thread::get_id()<<"} I will be watching over "<<name<<"."<<std::endl;
        while ((kill(pid, 0) != -1) || (kill(-pid, 0) != -1)) {
            waitpid(pid, NULL, 0);
        }
        std::cout<<"[watchdog]{"<<std::this_thread::get_id()<<"} Goodbye "<<name<<"."<<std::endl;
        this->destroyApp(name);
    });
    validateFork(pd);
    return switchApp(pd.name);
}
//
