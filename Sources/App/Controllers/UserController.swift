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
        routes.group("auth") { auth in
            auth.post("signup", use: signup)
            auth.post("login", use: login)
            auth.post("accessToken", use: refreshAccessToken)
            
            auth.group(UserAuthenticator()) { authenticated in
                authenticated.get("me", use: getCurrentUser)
            }
        }
    }
    
    private func getCurrentUser(_ req: Request) throws -> EventLoopFuture<User.Public> {
        let payload = try req.auth.require(Payload.self)
        
        return req.users
            .find(id: payload.userID)
            .unwrap(or: AuthenticationError.userNotFound)
            .map { $0.asPublic() }
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
    
    private func login(_ req: Request) throws -> EventLoopFuture<LoginResponse> {
        try LoginRequest.validate(content: req)
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        return req.users
            .find(email: loginRequest.email)
            .unwrap(or: AuthenticationError.invalidEmailOrPassword)
//            .guard({ $0.isEmailVerified }, else: AuthenticationError.emailIsNotVerified)
            .flatMap { user -> EventLoopFuture<User> in
                return req.password
                    .async
                    .verify(loginRequest.password, created: user.password)
                    .guard({ $0 == true }, else: AuthenticationError.invalidEmailOrPassword)
                    .transform(to: user)
        }
        .flatMap { user -> EventLoopFuture<User> in
            do {
                return try req.refreshTokens.delete(for: user.requireID()).transform(to: user)
            } catch {
                return req.eventLoop.makeFailedFuture(error)
            }
        }
        .flatMap { user in
            do {
                let token = req.random.generate(bits: 256)
                let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())
                
                return req.refreshTokens
                    .create(refreshToken)
                    .flatMapThrowing {
                        try LoginResponse(
                            user: user.asPublic(),
                            accessToken: req.jwt.sign(Payload(with: user)),
                            refreshToken: token
                        )
                }
            } catch {
                return req.eventLoop.makeFailedFuture(error)
            }
        }
    }
    
    private func refreshAccessToken(_ req: Request) throws -> EventLoopFuture<AccessTokenResponse> {
        let accessTokenRequest = try req.content.decode(AccessTokenRequest.self)
        let hashedRefreshToken = SHA256.hash(accessTokenRequest.refreshToken)
        
        return req.refreshTokens
            .find(token: hashedRefreshToken)
            .unwrap(or: AuthenticationError.refreshTokenOrUserNotFound)
            .flatMap { req.refreshTokens.delete($0).transform(to: $0) }
            .guard({ $0.expiresAt > Date() }, else: AuthenticationError.refreshTokenHasExpired)
            .flatMap { req.users.find(id: $0.$user.id) }
            .unwrap(or: AuthenticationError.refreshTokenOrUserNotFound)
            .flatMap { user in
                do {
                    let token = req.random.generate(bits: 256)
                    let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())
                    
                    let payload = try Payload(with: user)
                    let accessToken = try req.jwt.sign(payload)
                    
                    return req.refreshTokens
                        .create(refreshToken)
                        .transform(to: (token, accessToken))
                } catch {
                    return req.eventLoop.makeFailedFuture(error)
                }
        }
        .map { AccessTokenResponse(refreshToken: $0, accessToken: $1) }
    }
    
}
