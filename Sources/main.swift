import Vapor
import Redbird
import Environment

typealias EndpointHandler = Request throws -> ResponseRepresentable

do {

    //connect to redis
    let redis = try startRedis()

    //connect endpoints
    var endpoints = [String: [String: EndpointHandler]]()

    // start the server
    let app = Application()
    
    // middleware
    app.middleware.append(TimerMiddleware())
    
    // routes
    app.get("/", handler: addRoot())
    app.get("/v1/beep/redis", handler: addHealth(redis: redis))
    app.post("/v1/beep", handler: addHeartbeat_Post(redis: redis))
    app.get("/v1/beep/all", handler: addHeartbeat_GetAll(redis: redis))

    let port = Int(Environment().getVar("PORT") ?? "8080")
    app.start(port: port)
    
} catch {
    fatalError("\(error) Redis url: '\(Environment().getVar("REDIS_URL"))'")
}


