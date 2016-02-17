import Inquiline

func addRoot() -> EndpointHandler {
    return { request in
        return Response(.Ok, contentType: "text/plain", body: "Nothing to see here")
    }
}
