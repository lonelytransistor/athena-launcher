#include "AAPI_webServer.hpp"

WebServer::WebServer(ProcessManager *pm) {
    struct sockaddr_in serverAddress;
    serverAddress.sin_family = AF_INET;
    serverAddress.sin_port = htons(9876);
    serverAddress.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    
    int enable = 1;
    m_serverSocket = socket(AF_INET, SOCK_STREAM, 0);
    setsockopt(m_serverSocket, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int));
    bind(m_serverSocket, (struct sockaddr*)&serverAddress, sizeof(serverAddress));
    if (listen(m_serverSocket, BACKLOG) >= 0)
        m_running = true;
    
    m_api = new AAPI(pm);
}
WebServer::~WebServer() {
    shutdown(m_serverSocket, SHUT_RDWR);
    close(m_serverSocket);
}
void WebServer::respond(int* socket_ptr) {
    int socket = *socket_ptr;
    char buf[2560];
    int rcv_len = recv(socket, buf, 2560, 0);
    buf[rcv_len] = '\0';

    std::string GUID;
    std::string PAYLOAD;
    std::string CMD;
    std::cmatch cmre;
    {
        std::regex re("AthenaGUID:\\s+([0-9a-f]+)");
        std::regex_search(buf, cmre, re);
        GUID = cmre.str(1);
    }
    {
        std::regex re("AthenaPayload:\\s+(.*)");
        std::regex_search(buf, cmre, re);
        PAYLOAD = cmre.str(1);
    }
    {
        std::regex re("AthenaCommand:\\s+([0-9A-Za-z]+)");
        std::regex_search(buf, cmre, re);
        CMD = cmre.str(1);
    }
    std::string buf_out;
    buf_out = "HTTP/1.1 200 OK\r\n";
    buf_out+= "Connection: close\r\n";
    buf_out+= "Server: AthenaLocalServer\r\n";
    if (GUID.size() && CMD.size()) {
        std::cout<<"GUID: \""<<GUID<<"\", requesting: \""<<CMD<<"\""<<std::endl;
        buf_out+= "Content-Type: text/plain;charset=UTF-8\r\n";
        buf_out+= "AthenaResult: true\r\n\n";
        try {
            buf_out+= m_api->eval(CMD, GUID, PAYLOAD);
        } catch (std::exception& e) {
            std::cerr<< e.what()<<'\n';
        }
    } else {
        buf_out+= "Content-Type: text/html;charset=UTF-8\r\n\n";
        buf_out+= "<html><body>"
                  "<h1>You should not be able to see this! Please report how you managed this!</h1>"
                  "<h2>Invalid request.</h2><br>"
                  "<h3>This is not a webserver. This is only for internal use for Athena API access.</h3>"
                  "</body></html>";
    }
    send(socket, buf_out.c_str(), buf_out.size(), 0);
    
    shutdown(socket, SHUT_RDWR);
    close(socket);
    *socket_ptr = -1;
}
void WebServer::serve() {
    socklen_t addrlen;
    int slot = 0;
    
    while (m_running) {
        while (m_clients[slot].socket != -1) {
            slot = (slot+1)%CONNMAX;
        }
        
        m_clients[slot].socket = accept(m_serverSocket, NULL, NULL);
        
        if (m_clients[slot].socket > 0) {
            int* socket_ptr = &m_clients[slot].socket;
            m_clients[slot].thread = new std::thread([this, socket_ptr](){this->respond(socket_ptr);});
        }
        usleep(10);
    }
}
