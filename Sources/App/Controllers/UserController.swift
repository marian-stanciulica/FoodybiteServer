//
//  UserController.swift
//  
//
//  Created by Marian Stanciulica on 01.07.2022.
//

import Vapor
import FluentKit

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("users", use: getAll)
        routes.post("signup", use: signup)
        routes.post("login", use: login)
    }
    
    func getAll(_ request: Request) throws -> EventLoopFuture<[User.Public]> {
        return User.query(on: request.db).all().convertToPublic()
    }
    
    func signup(_ request: Request) throws -> EventLoopFuture<User.Public> {
        let user = try request.content.decode(User.self)
        user.password = try Bcrypt.hash(user.password)
        return user.save(on: request.db).map { user.convertToPublic() }
    }
    
    func login(_ request: Request) throws -> EventLoopFuture<User.Public> {
        let input = try request.content.decode(LoginData.self)
        let password = try Bcrypt.hash(input.password)
        
        return User.query(on: request.db)
            .group(.and) { and in
                and.filter(\.$email == input.email)
//                and.filter(\.$password == input.password)
            }
            .first()
            .flatMapThrowing { user in
                if let user = user {
                    return user.convertToPublic()
                } else {
                    throw Abort(.notFound)
                }
            }
    }
    
}

struct LoginData: Content {
    let email: String
    let password: String
}
