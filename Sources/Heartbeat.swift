import Redbird
import Inquiline
import class Foundation.NSDate

func addHeartbeat_Post(redis: Redbird) -> EndpointHandler {
	return { request in 

		do {
			guard let body = request.body else { throw Error("No body supplied") }

			//parse from string/data
			var dict = try JSON.parseDictionary(fromString: body)

			//validate event for required fields
			guard validateEvent(dict) else { throw Error("Event did not pass validation") }

			if let testGen = dict["test_generated"] as? Bool where testGen {
				print("Not saving a test event")
				return Response(.Created)
			}

			//get a new id for the event
			let id = try redis.command("INCR", params: ["next_event_id"]).toInt()
			dict["event_id"] = id
			dict["timestamp"] = Int(NSDate().timeIntervalSince1970 * 1000) //milliseconds

			//turn back into data/string
			let out = try JSON.serialize(dict)

			//save this to redis
			let res = try redis.command("ZADD", params: ["events", String(id), out])
			return Response(.Created)
		} catch let e as Error {
			return Response(.BadRequest, body: "\(e.message)")
		} catch {
			return Response(.BadRequest)
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
		let out = "[" + strings.joinWithSeparator(", ") + "]\n"

		return Response(.Ok, contentType: "application/json", body: out)
	}
}

