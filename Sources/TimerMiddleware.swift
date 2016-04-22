//
//  TimerMiddleware.swift
//  ekg-swift
//
//  Created by Honza Dvorsky on 4/22/16.
//
//

import Vapor
import C7

class TimerMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        let start = now()
        var response = try next.respond(to: request)
        let duration = now() - start
        let ms = Double(Int(duration * 1000 * 1000))/1000
        let text = "\(ms) ms"
        response.headers["vapor-duration"] = Response.Headers.Values(text)
        return response
    }
}
