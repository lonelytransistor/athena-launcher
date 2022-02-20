#ifndef __AAPI_UINPUT_HPP__
#define __AAPI_UINPUT_HPP__
#include <linux/uinput.h>
#include <stdexcept>
#include <exception>
#include <cerrno>
#include <inttypes.h>
#include <cstring>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/fs.h>

class uinput {
    int fd;
public:
    uinput();
    ~uinput();
    void send(uint16_t code, bool down);
};

#endif //__AAPI_UINPUT_HPP__
