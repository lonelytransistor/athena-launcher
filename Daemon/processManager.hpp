#ifndef __PROCESSMANAGER_HPP__
#define __PROCESSMANAGER_HPP__

#include <iostream>
#include <string.h>
#include <errno.h>
#include <exception>
#include <linux/fb.h>
#include <linux/input.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdexcept>
#include <vector>
#include <fstream>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <mutex>
#include <map>
#include <string>
#include <vector>
#include <functional>
#include <thread>
#include <sys/wait.h>
#include <signal.h>
#include <unistd.h>
#include <time.h>
#include "mxcfb.h"
#include "png.h"

struct ProcessDescription {
    pid_t pid;
    std::string name;
    std::string thumbnail;
    std::string thumbnailJPG;
    std::string thumbnailPNG;
    std::string path;
    bool running;
    std::thread *watchdog;
    std::thread *killer;
};

#define WAVEFORM_MODE_INIT	0x0	/* Screen goes to white (clears) */
#define WAVEFORM_MODE_DU	0x1	/* Grey->white/grey->black */
#define WAVEFORM_MODE_GC16	0x2	/* High fidelity (flashing) */
#define WAVEFORM_MODE_GC4	0x3	/* Lower fidelity */
#define WAVEFORM_MODE_A2	0x4	/* Fast black/white animation */
#define WAVEFORM_MODE_DU4 0x7
#define WAVEFORM_MODE_REAGLD 0x9
#define WAVEFORM_MODE_AUTO 257
#define TEMP_USE_REMARKABLE_DRAW 0x0018
#define EPDC_FLAG_EXP1 0x270ce20
#define EPDC_FLAG_USE_DITHERING_ALPHA 0x3ff00000
#define FB_NAME "/dev/fb0"
//#define FB_NAME "/dev/shm/swtfb.01"

class ProcessManager {
private:
    std::map<std::string, ProcessDescription> m_runningApps;
    std::string m_currentApp;
    std::string m_launcherApp;
    std::mutex m_mutex;
    
    std::string PWRBTN_DEV = "/dev/input/by-path/platform-30370000.snvs:snvs-powerkey-event";
    std::string TMP_XOCHITL_PID = "/tmp/xochitl.pid";
    
    void* m_fb;
    char* m_fb_buf;
    char* m_fb_buf_jpg;
    long unsigned int m_fb_buf_jpg_sz = 0;
    int m_fb_sz;
    int m_fb_width;
    int m_fb_height;
    int m_fb_fd;
    
    int m_hook_pwrbtn;
    bool m_hook_exclusive;
    std::thread* m_hook_thread;
    
    void BTNHookThread();
    void restoreFramebuffer(std::string path);
    void saveFramebufferRAW(std::string path);
    void destroyApp(std::string appName);
    void eraseApp(std::string appName);
    void validateFork(ProcessDescription& pd);
    int startLauncher();
    void grabExclusiveKbdHook(int fd, bool grab);
    void forwardExclusiveKbdEvent(int fd, std::vector<input_event> event);
    void clearEventQueue(int fd);
public:
    int saveFramebufferJPG(std::string path);
    int saveFramebufferPNG(std::string path);
    std::vector<std::string> getApps();
    std::string getCurrentApp() {
        return m_currentApp;
    }
    std::string getLauncherApp() {
        return m_launcherApp;
    }
    int switchApp(std::string appName);
    int startApp(std::string appName, std::string appPath, bool preload = true, pid_t pid = 0);
    int killApp(std::string appName);
    bool isAppRunning(std::string appName);
    void declareLauncherHotkey(int key, bool exclusive_hook);
    
    ProcessManager();
    ~ProcessManager();
};

#endif //__PROCESSMANAGER_HPP__
