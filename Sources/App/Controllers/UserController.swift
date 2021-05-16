//
//  File.swift
//  
//
//  Created by Hasan Oztunc on 16.05.2021.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let usersRoutes = routes.grouped("users")
        
        usersRoutes.post(use: createUser)
        usersRoutes.post("login", use: login)
    }
    
    func createUser(_ req: Request) throws -> EventLoopFuture<UserResponse> {
        let decodedUser = try req.content.decode(User.self)
        decodedUser.password = try Bcrypt.hash(decodedUser.password)
        
        let user = User(
            name: decodedUser.name,
            phone: decodedUser.phone,
            email: decodedUser.email,
            password: decodedUser.password)
        
        return user
            .create(on: req.db)
            .map({
                return UserResponse(name: user.name, phone: user.phone, email: user.email)
            })
    }
    
    func login(_ req: Request) throws -> EventLoopFuture<UserResponse> {
        let userToLogin = try req.content.decode(UserLogin.self)
        
        return User
            .query(on: req.db)
            .filter(\.$email == userToLogin.email)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing({ dbUser in
                let verified = try dbUser.verify(password: userToLogin.password)
                
                if !verified {
                    throw Abort(.unauthorized)
                }
                
                req.auth.login(dbUser)
                
                let user = try req.auth.require(User.self)
                return try UserResponse(
                    name: user.name,
                    phone: user.phone,
                    email: user.email,
                    token: user.generateToken(req.application))
            })
    }
}
