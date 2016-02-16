import Inquiline
import Curassow
import Frank
import Redbird
import Environment

do {

	let redisUrl = Environment().getVar("REDIS_URL")
	print("redis url: \(redisUrl)")

	// let redis = try Redbird(address: "127.0.0.1", port: 6379)

	get { request in
	  	return Response(.Ok, contentType: "text/plain", body: "Pong")
	}

	get("v1") { request in
		return Response(.Ok, contentType: "text/plain", body: "Did things")
	}

	// start the server
	serve(call)
} catch {
	fatalError("\(error)")
}

// func dictionarifyArguments
