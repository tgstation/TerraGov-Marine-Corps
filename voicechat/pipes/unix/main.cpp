#include "byondapi/byondapi_cpp_wrappers.h"

#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <cstring>

extern "C" BYOND_EXPORT CByondValue Echo(u4c n, ByondValue v[]) {
    CByondValue ret;
    if (n != 1 || !v[0].IsStr()) {
        ByondValue_Clear(&ret);
        return ret;
    }
    ret = v[0];
    return ret;
}

extern "C" BYOND_EXPORT CByondValue SendJSON(u4c n, ByondValue v[]) {
    CByondValue ret;
    if (n < 1 || !v[0].IsStr()) {
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    // Query the required buffer size first
    u4c buflen = 0;
    bool success = Byond_ToString(&v[0], nullptr, &buflen);
    if (!success && buflen == 0) {
        // Error querying size
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    // Allocate buffer and get the string
    char* buf = new char[buflen];
    success = Byond_ToString(&v[0], buf, &buflen);
    if (!success) {
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    // buflen now holds the actual length +1 (null terminator), so str_len is buflen -1
    u4c str_len = buflen - 1;

    int sock = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sock == -1) {
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, "byond_node.sock", sizeof(addr.sun_path) - 1);

    if (connect(sock, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
        close(sock);
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    ssize_t sent = write(sock, buf, str_len);
    close(sock);
    delete[] buf;

    if (sent == static_cast<ssize_t>(str_len)) {
        ByondValue_SetNum(&ret, 1.0f);
        return ret;
    } else {
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }
}