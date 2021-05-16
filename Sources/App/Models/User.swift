//
//  File.swift
//  
//
//  Created by Hasan Oztunc on 16.05.2021.
//

import Fluent
import Vapor
import JWT

final class User: Model,Content {
    
    static let schema: String = Schemas.Users

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "phone")
    var phone: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @OptionalField(key: "createdBy")
    var createdBy: String?
    
    @Timestamp(key: "createdOn", on: .create)
    var createdOn: Date?
    
    @OptionalField(key: "updatedBy")
    var updatedBy: String?
    
    @Timestamp(key: "updatedOn", on: .update)
    var updatedOn: Date?
    
    init() {}
    
    init(id: UUID? = nil, name: String, phone: String, email: String, password: String) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.password = password
        self.createdBy = "app"
        self.updatedBy = "app"
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey: KeyPath<User, Field<String>> = \User.$email
        
    static var passwordHashKey: KeyPath<User, Field<String>> = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

extension User {
    
    func generateToken(_ app: Application) throws -> String {
        var expDate = Date()
        expDate.addTimeInterval((86400 * 7))
        
        let exp = ExpirationClaim(value: expDate)
        
        return try app
            .jwt
            .signers
            .get(kid: .private)!
            .sign(JWTBearerAuthenticatorPayload(id: self.id, email: self.email, exp: exp))
    }
}

struct UserLogin: Content {
    var email: String
    var password: String
}

struct UserResponse: Content {
    
    var name: String
    var phone: String
    var email: String
    var token: String?
}
