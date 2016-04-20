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
    if let portCandidate = redisUrl.characters.split(separator: ":").map(String.init).last {
        if let p = Int(portCandidate) {
            port = p
        }
    }
    
    let config = RedbirdConfig(address: address, port: port, password: parsed.password)
    let redis = try Redbird(config: config)
    
    return redis
}