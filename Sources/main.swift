import Curassow
import Nest
import Inquiline
import Redbird

typealias EndpointHandler = RequestType throws -> ResponseType

do {

    //connect to redis
    let redis = try startRedis()

    //connect endpoints
    var endpoints = [String: [String: EndpointHandler]]()

    endpoints["/"] = ["GET": addRoot()]
    endpoints["/v1/beep/redis"] = ["GET": addHealth(redis)]
    endpoints["/v1/beep"] = ["POST": addHeartbeat_Post(redis)]
    endpoints["/v1/beep/all"] = ["GET": addHeartbeat_GetAll(redis)]

    // start the server
    serve { request in
        do {
            return try endpoints[request.path]?[request.method]?(request) ?? Response(.NotFound)
        } catch {
            let s = "Error occured on request: \(request.path), "
            var e = "Error: " //crashes when we print error :(
            // e += "\(error)"
            let out = s + e
            print(out)
            return Response(.InternalServerError)
        }
    }
} catch {
    fatalError("Redis at \(redis.address):\(redis.port): \(error)")
}


