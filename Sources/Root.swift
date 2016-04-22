import Vapor

func addRoot(app: Application) -> EndpointHandler {
    return { request in
        return try app.view("index.stencil", context: 
        	[
        		"csspath": "/stylesheets/style.css",
	        	"ekglink": "https://github.com/czechboy0/ekg-swift",
	        	"buildalink": "https://github.com/czechboy0/buildasaur"
        	]
    	)
    }
}
