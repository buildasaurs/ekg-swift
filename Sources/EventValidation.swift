
func validate(event: [String: Any]) -> Bool {

	guard let _ = event["app"] else { return false }
	guard let _ = event["token"] else { return false }
	guard let _ = event["event_type"] else { return false }
	guard let _ = event["version"] else { return false }
	guard let _ = event["build"] else { return false }

	return true
}
