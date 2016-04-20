import Vapor
import Redbird

func addHealth(redis: Redbird) -> EndpointHandler {

    return { request in

        //healthcheck, ping redis - only return 200 if we get PONG
        func redisHealth() -> (Bool, String) {
            do {
                let ret = try redis.command("PING").toString()
                if ret == "PONG" {
                    return (true, ret)
                } else {
                    return (false, ret)
                }
            } catch {
                return (false, String(error))
            }
        }

        let redisCheck = redisHealth()

        let resp = [
            "redis: \(redisCheck.1)"
        ].joined(separator: "\n")

        let status: Response.Status = (redisCheck.0 ? .ok : .internalServerError)
        return Response(status: status, text: resp)
    }
}