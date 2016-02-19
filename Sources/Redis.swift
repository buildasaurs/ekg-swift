import Environment
import Redbird
import Darwin

func startRedis() throws -> Redbird {

    guard let redisUrl = Environment().getVar("REDIS_URL") else {
        throw Error("No REDIS_URL environment variable provided")
    }

    fputs("Have redis url: \(redisUrl)\n", __stderrp)

    let parsed = URLParser(url: redisUrl)
    let address = parsed.host ?? "127.0.0.1"
    let port = parsed.port ?? 6379

    let redis = try Redbird(address: address, port: port)
    if let password = parsed.password {
        try redis.auth(password: password)
    }

    return redis
}