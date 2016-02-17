
struct Error: ErrorType {
    let message: String
    init(_ message: String) {
        self.message = message
    }

    var description: String {
        return "Error: '\(self.message)'"
    }
}

