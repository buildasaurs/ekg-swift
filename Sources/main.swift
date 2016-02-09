#if os(Linux)
import Glibc
#endif
import Inquiline
import Curassow

serve {
    return Response(.Ok, contentType: "text/plain", body: "Hello World")
}
