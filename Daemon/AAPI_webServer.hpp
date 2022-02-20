#ifndef __AAPI_WEBSERVER_H__
#define __AAPI_WEBSERVER_H__

#include "AAPI_api.hpp"
#include <exception>

struct ClientStruct {
    int socket = -1;
    std::thread *thread;
};
class WebServer {
private:
    static const int BACKLOG = 100;
    static const int CONNMAX = 10;
    
    int m_serverSocket;
    struct ClientStruct m_clients[CONNMAX];
    bool m_running = false;
    AAPI *m_api;
    
    void respond(int* socket);
public:
    WebServer(ProcessManager *pm);
    ~WebServer();

    void serve();
};

#endif //__AAPI_WEBSERVER_H__
