import Foundation

struct JSON {

    static func parse(fromString string: String) throws -> AnyObject {

        //in the future take the byte stream instead of string
        //assuming UTF-8 
        guard let data = string.dataUsingEncoding(NSUTF8StringEncoding) else {
            throw Error("Failed to parse incoming body data")
        }

        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
            return object
        } catch {
            throw Error("Failed to parse body data, error \(error)")
        }
    }

    static func parseDictionary(fromString string: String) throws -> [String: AnyObject] {
        guard let dict = try JSON.parse(fromString: string) as? [String: AnyObject] else {
            throw Error("Body is not a JSON object")   
        }
        return dict
    }
}

