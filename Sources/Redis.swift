import Environment
import Redbird

func startRedis() throws -> Redbird {

    guard let redisUrl = Environment().getVar("REDIS_URL") else {
        throw Error("No REDIS_URL environment variable provided")
    }

    let parsed = URLParser(url: redisUrl)
    let address = parsed.host ?? "127.0.0.1"
    //Swift Foundation has broken .port for NSURLComponents, so we need to hack here
    //split string by colon, take last element and try to create an Int out of it.
    var port: Int = 6379
    if let portCandidate = redisUrl.characters.split(":").map(String.init).last {
        if let p = Int(portCandidate) {
            port = p
        }
    }
    
    let redis = try Redbird(address: address, port: port)
    if let password = parsed.password {
        try redis.auth(password: password)
    }

    return redis
}