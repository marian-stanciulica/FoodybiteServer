//
//  UserController.swift
//  
//
//  Created by Marian Stanciulica on 01.07.2022.
//

import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("signup", use: signup)
    }
    
    func signup(_ request: Request) throws -> EventLoopFuture<User.Public> {
        let user = try request.content.decode(User.self)
        user.password = try Bcrypt.hash(user.password)
        return user.save(on: request.db).map { user.convertToPublic() }
    }
    
}
