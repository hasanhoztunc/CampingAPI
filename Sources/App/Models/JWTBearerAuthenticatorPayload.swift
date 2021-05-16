//
//  File.swift
//  
//
//  Created by Hasan Oztunc on 16.05.2021.
//

import Vapor
import JWT

struct JWTBearerAuthenticatorPayload: Authenticatable, JWTPayload {
    
    var id: UUID?
    var email: String
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}
