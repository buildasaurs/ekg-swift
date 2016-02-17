import class Foundation.NSURLComponents //available on both linux and osx already

struct URLParser {

    var host: String? { return self.components.host }
    var password: String? { return self.components.password }
    var port: Int? { return self.components.port as? Int }

    let components: NSURLComponents
    init(url: String) {
        self.components = NSURLComponents(string: url)!
    }
}
