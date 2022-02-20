#include "AAPI_webServer.hpp"
#include "processManager.hpp"

int main(int argc, char** argv) {
    try {
        ProcessManager pm;
        WebServer dupa(&pm);
        
        dupa.serve();
    } catch (std::exception& e) {
        std::cerr<<"Crashing... Uncaught exception: "<<e.what()<<std::endl;
    }
    return 127;
}
