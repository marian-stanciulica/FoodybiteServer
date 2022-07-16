//
//  UserController.swift
//  
//
//  Created by Marian Stanciulica on 01.07.2022.
//

import Vapor
import FluentKit

struct NewSession: Content {
    let token: String
    let user: User.Public
}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("users")
        usersRoute.post("signup", use: signup)
        
//        let tokenProtected = usersRoute.grouped(Token.authenticator())
//        tokenProtected.get("me", use: getMe)
//
//        let passwordProtected = usersRoute.grouped(User.authenticator())
//        passwordProtected.post("login", use: login)
    }
    
    private func getMe(_ request: Request) throws -> User.Public {
        let user = try request.auth.require(User.self)
        return user.asPublic()
    }
    
    private func signup(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try RegisterRequest.validate(content: req)
        let registerRequest = try req.content.decode(RegisterRequest.self)
        guard registerRequest.password == registerRequest.confirm_password else {
            throw AuthenticationError.passwordsDontMatch
        }
        
        return req.password
            .async
            .hash(registerRequest.password)
            .flatMapThrowing { try User(from: registerRequest, hash: $0) }
            .flatMap { user in
                req.users
                    .create(user)
                    .flatMapErrorThrowing {
                        if let dbError = $0 as? DatabaseError, dbError.isConstraintFailure {
                            throw AuthenticationError.emailAlreadyExists
                        }
                        throw $0
                }
//                .flatMap { req.emailVerifier.verify(for: user) }
        }
        .transform(to: .created)
    }
    
//    private func login(_ request: Request) async throws -> NewSession {
//        let user = try request.auth.require(User.self)
//        let token = user.createToken(userID: user.id!)
//        try await token.save(on: request.db)
//        return NewSession(token: token.value, user: user.asPublic())
//    }
    
}
