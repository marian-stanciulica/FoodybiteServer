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
            auth.on(.POST, "signup", body: .collect(maxSize: "10mb"), use: signup)
            auth.post("login", use: login)
            
            auth.group(UserAuthenticator()) { authenticated in
                authenticated.post("accessToken", use: refreshAccessToken)
                
                authenticated.post("changePassword", use: changePassword)
                authenticated.post("account", use: updateAccount)
                authenticated.delete("account", use: deleteAccount)
                
                authenticated.post("logout", use: logout)
            }
        }
        
        routes.group("review") { review in
            review.group(UserAuthenticator()) { authenticated in
                authenticated.post("", use: postReview)
                authenticated.get("", use: getAllReviews)
                authenticated.get(":placeID", use: getReviewsForPlace)
            }
        }
    }
    
    private func signup(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try RegisterRequest.validate(content: req)
        let registerRequest = try req.content.decode(RegisterRequest.self)
        
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
                            token: AuthToken(
                                accessToken: req.jwt.sign(Payload(with: user)),
                                refreshToken: token
                            )
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
    
    private func changePassword(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let payload = try req.auth.require(Payload.self)

        try ChangePasswordRequest.validate(content: req)
        let changePasswordRequest = try req.content.decode(ChangePasswordRequest.self)
        
        return req.users
            .find(id: payload.userID)
            .unwrap(or: AuthenticationError.userNotFound)
            .flatMap { user -> EventLoopFuture<Void> in
                return req.password
                    .async
                    .hash(changePasswordRequest.newPassword)
                    .flatMap { digest in
                        req.users.set(\.$password, to: digest, for: user.id!)
                }
            }
            .transform(to: .ok)
    }
    
    private func logout(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let payload = try req.auth.require(Payload.self)
        
        return req.users
            .find(id: payload.userID)
            .unwrap(or: AuthenticationError.userNotFound)
            .flatMap { user -> EventLoopFuture<HTTPStatus> in
                do {
                    return try req.refreshTokens.delete(for: user.requireID()).transform(to: .ok)
                } catch {
                    return req.eventLoop.makeFailedFuture(error)
                }
            }
    }
    
    private func updateAccount(_ req: Request) throws -> EventLoopFuture<User.Public> {
        let payload = try req.auth.require(Payload.self)

        try UpdateAccountRequest.validate(content: req)
        let updateAccountRequest = try req.content.decode(UpdateAccountRequest.self)
        
        return req.users
            .find(id: payload.userID)
            .unwrap(or: AuthenticationError.userNotFound)
            .flatMap { user -> EventLoopFuture<User.Public> in
                user.name = updateAccountRequest.name
                user.email = updateAccountRequest.email
                user.profileImage = updateAccountRequest.profileImage
                return user.update(on: req.db).map { user.asPublic() }
            }
    }
    
    private func deleteAccount(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let payload = try req.auth.require(Payload.self)
        return req.users.delete(id: payload.userID).transform(to: .ok)
    }
    
    private func postReview(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let payload = try req.auth.require(Payload.self)
        
        try PostReviewRequest.validate(content: req)
        let postReviewRequest = try req.content.decode(PostReviewRequest.self)
        
        let review = Review(userID: payload.userID,
                            restaurantID: postReviewRequest.restaurantID,
                            text: postReviewRequest.text,
                            stars: postReviewRequest.stars,
                            createdAt: postReviewRequest.createdAt)
        
        return req.reviews.create(review).transform(to: .ok)
    }
    
    private func getAllReviews(_ req: Request) throws -> EventLoopFuture<[ReviewResponse]> {
        let payload = try req.auth.require(Payload.self)
        
        return req.users
            .find(id: payload.userID)
            .unwrap(or: AuthenticationError.userNotFound)
            .flatMap { user in
                user.$reviews
                    .get(on: req.db)
                    .mapEach {
                        ReviewResponse(restaurantID: $0.restaurantID, profileImageData: user.profileImage, authorName: user.name, reviewText: $0.text, rating: $0.stars, createdAt: $0.createdAt)
                    }
            }
    }
    
    private func getReviewsForPlace(_ req: Request) throws -> EventLoopFuture<[ReviewResponse]> {
        let payload = try req.auth.require(Payload.self)

        guard let placeID = req.parameters.get("placeID") else {
            throw Abort(.badRequest)
        }
        
        return req.users
            .find(id: payload.userID)
            .unwrap(or: AuthenticationError.userNotFound)
            .flatMap { user in
                user.$reviews
                    .query(on: req.db)
                    .filter(\.$restaurantID == placeID)
                    .all()
                    .mapEach {
                        ReviewResponse(restaurantID: $0.restaurantID, profileImageData: user.profileImage, authorName: user.name, reviewText: $0.text, rating: $0.stars, createdAt: $0.createdAt)
                    }
            }
    }
    
}
