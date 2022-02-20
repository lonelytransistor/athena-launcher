#include "AAPI_uinput.hpp"

uinput::uinput() {
    fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (fd < 0) {
        throw std::invalid_argument(std::string("Unable to open uinput: ") + strerror(errno));
    }
    
    if (ioctl(fd, UI_SET_EVBIT, EV_SYN) < 0)
        throw std::invalid_argument(std::string("Unable to ioctl uinput: ") + strerror(errno));
    if (ioctl(fd, UI_SET_EVBIT, EV_KEY) < 0)
        throw std::invalid_argument(std::string("Unable to ioctl uinput: ") + strerror(errno));
    for (uint8_t i=KEY_ESC; i<KEY_PAUSE+1; i++) {
        if (ioctl(fd, UI_SET_KEYBIT, i) < 0)
            throw std::invalid_argument(std::string("Unable to ioctl uinput: ") + strerror(errno));
    }

    struct uinput_setup usetup;
    memset(&usetup, 0, sizeof(usetup));
    usetup.id.bustype = BUS_USB;
    usetup.id.vendor = 0x1234;
    usetup.id.product = 0x5678;
    strcpy(usetup.name, "Virtual keyboard");

    if (ioctl(fd, UI_DEV_SETUP, &usetup) < 0)
        throw std::invalid_argument(std::string("Unable to ioctl uinput: ") + strerror(errno));
    if (ioctl(fd, UI_DEV_CREATE) < 0)
        throw std::invalid_argument(std::string("Unable to ioctl uinput: ") + strerror(errno));
}
uinput::~uinput() {
    ioctl(fd, UI_DEV_DESTROY);
    close(fd);
}
void uinput::send(uint16_t code, bool down) {
    struct input_event ie;

    ie.type = EV_KEY;
    ie.code = code;
    ie.value = down?1:0;
    ie.time.tv_sec = 0;
    ie.time.tv_usec = 0;
    write(fd, &ie, sizeof(ie));

    ie.type = EV_SYN;
    ie.code = SYN_REPORT;
    ie.value = 0;
    ie.time.tv_sec = 0;
    ie.time.tv_usec = 0;
    write(fd, &ie, sizeof(ie));
}
