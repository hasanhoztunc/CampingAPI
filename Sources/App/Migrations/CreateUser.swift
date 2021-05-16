//
//  File.swift
//  
//
//  Created by Hasan Oztunc on 16.05.2021.
//

import Fluent
import Vapor

struct CreateUser: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(Schemas.Users)
            .id()
            .field("name", .custom("character varying(60)"), .required)
            .field("phone", .custom("character varying(17)"), .required)
            .field("email", .custom("character varying(60)"), .required)
            .field("password", .string, .required)
            .field("createdBy", .custom("character varying(60)"), .required)
            .field("createdOn", .datetime, .required)
            .field("updatedBy", .custom("character varying(60)"), .required)
            .field("updatedOn", .datetime, .required)
            .unique(on: "email")
            .unique(on: "phone")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(Schemas.Users)
            .delete()
    }
}
