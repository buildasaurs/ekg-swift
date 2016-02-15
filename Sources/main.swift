import Inquiline
import Curassow
import Frank
import Redbird

do {

	let redis = try Redbird(port: 6379)

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

