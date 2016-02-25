
func validateEvent(event: [String: Any]) -> Bool {

	guard let app = event["app"] else { return false }
	guard let token = event["token"] else { return false }
	guard let eventType = event["event_type"] else { return false }
	guard let version = event["version"] else { return false }
	guard let build = event["build"] else { return false }

	return true
}
