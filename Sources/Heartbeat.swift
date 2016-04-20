import Redbird
import Vapor
import class Foundation.NSDate

func addHeartbeat_Post(redis: Redbird) -> EndpointHandler {
	return { request in 

		do {
            var body = request.body
            let bytes = try body.becomeBuffer().bytes
            
			//parse from string/data
			var dict = try JSONUtils.parseDictionary(fromData: bytes)
            
			//validate event for required fields
			guard validate(event: dict) else { throw Error("Event did not pass validation") }

			if let testGen = dict["test_generated"] as? Bool where testGen {
				print("Not saving a test event")
                return Response(status: .created)
			}

			//get a new id for the event
			let id = try redis.command("INCR", params: ["next_event_id"]).toInt()
			dict["event_id"] = id
			dict["timestamp"] = Int(NSDate().timeIntervalSince1970 * 1000) //milliseconds

			//turn back into data/string
			let out = try JSONUtils.serialize(dict: dict)

			//save this to redis
			try redis.command("ZADD", params: ["events", String(id), out])
            return Response(status: .created)
		} catch let e as Error {
			return Response(status: .badRequest, text: "\(e.message)")
		} catch {
			return Response(status: .badRequest)
		}
	}
}

func addHeartbeat_GetAll(redis: Redbird) -> EndpointHandler {
	return { _ in 

		//go to redis and ask for all events. throws on .toArray() if an error was returned
		let response = try redis.command("ZRANGE", params: ["events", String(0), String(-1)])

		if response.respType == .Error {
			print("\(response)")
			throw response as! RespError
		}

		let arr = try response.toArray()

		//convert it back into a regular array of strings
		let strings = try arr.map { try $0.toString() }

		//since we don't yet have JSON serialization, just wrap the elements in a json array as string and return
		let out = "[" + strings.joined(separator: ", ") + "]\n"
        let data = out.data
        
        return Response(status: .ok, headers: ["content-type":"application/json"], body: data)
	}
}

