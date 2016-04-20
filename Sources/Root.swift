import Vapor

func addRoot() -> EndpointHandler {
    return { request in
        return "Nothing to see here"
    }
}
