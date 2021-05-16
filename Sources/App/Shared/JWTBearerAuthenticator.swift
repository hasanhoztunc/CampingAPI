//
//  File.swift
//  
//
//  Created by Hasan Oztunc on 16.05.2021.
//

import Vapor
import JWT

struct JWTBearerAuthenticator: JWTAuthenticator {
    typealias Payload = JWTBearerAuthenticatorPayload
    
    func authenticate(jwt: Payload, for request: Request) -> EventLoopFuture<Void> {
        do {
            try jwt.verify(using: request.application.jwt.signers.get()!)
            
            return User
                .find(jwt.id, on: request.db)
                .unwrap(or: Abort(.notFound))
                .map({
                    request.auth.login($0)
                })
        } catch {
            return request.eventLoop.makeSucceededFuture(())
        }
    }
}
