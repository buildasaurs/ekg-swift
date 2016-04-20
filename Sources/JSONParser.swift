import Jay

struct JSONUtils {

    static func parse(fromData data: [UInt8]) throws -> Any {

        //in the future take the byte stream instead of string
        //assuming UTF-8 
        do {
            let object = try Jay().jsonFromData(data)
            return object
        } catch {
            throw Error("Failed to parse body data, error \(error)")
        }
    }

    static func serialize(dict: [String: Any]) throws -> String {
        do {
            let data = try Jay().dataFromJson(JaySON(dict))
            let str = try data.string()
            return str
        } catch {
           throw Error("Failed to serialize JSON, error \(error)") 
        }
    }

    static func parseDictionary(fromData data: [UInt8]) throws -> [String: Any] {
        guard let dict = try JSONUtils.parse(fromData: data) as? [String: Any] else {
            throw Error("Body is not a JSON object")
        }
        return dict
    }
}

