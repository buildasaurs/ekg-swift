import Jay

struct JSON {

    static func parse(fromString string: String) throws -> Any {

        //in the future take the byte stream instead of string
        //assuming UTF-8 
        let data = Array(string.utf8)
        do {
            let object = try Jay().jsonFromData(data)
            return object
        } catch {
            throw Error("Failed to parse body data, error \(error)")
        }
    }

    static func parseDictionary(fromString string: String) throws -> [String: Any] {
        guard let dict = try JSON.parse(fromString: string) as? [String: Any] else {
            throw Error("Body is not a JSON object")
        }
        return dict
    }
}

