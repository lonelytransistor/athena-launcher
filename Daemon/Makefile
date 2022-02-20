CROSS_COMPILE   ?= arm-remarkable-linux-gnueabihf-
ARCH            ?= arm
KERNEL_DIR      ?= /usr/src/linux

CC              := $(CROSS_COMPILE)g++
LD		:= $(CROSS_COMPILE)ld
INCLUDE		:= -I$(SYSROOT)/usr/include
CPPFLAGS        := $(INCLUDE) -Wno-psabi -mfloat-abi=hard
LIBRARIES	:= -L./mosquitto/lib/cpp/ -L./mosquitto/lib/ -L$(SYSROOT)/usr/lib -L$(SYSROOT)/opt/lib
LDFLAGS		:= $(LIBRARIES) -lsystemd -lpthread -lpng -lz -lmosquittopp_static -lmosquitto_static

all: zeus

clean:
	rm -f *.o
	rm -f zeus

%.o: %.cpp
	$(CC) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<

zeus: AAPI_api.o  AAPI_uinput.o  AAPI_webServer.o  main.o  processManager.o
	$(CC) -o $@ $^ $(LDFLAGS)
