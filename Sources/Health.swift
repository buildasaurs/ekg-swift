import Nest
import Redbird
import Inquiline

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
        ].joinWithSeparator("\n")

        let status: Status = (redisCheck.0 ? .Ok : .InternalServerError)
        return Response(status, contentType: "text/plain", body: resp)
    }
}