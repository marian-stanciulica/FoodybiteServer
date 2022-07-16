//
//  CreateUser.swift
//  
//
//  Created by Marian Stanciulica on 01.07.2022.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users")
            .id()
            .field("password_hash", .string, .required)
            .field("email", .string, .required)
            .field("name", .string, .required)
            .field("profile_image_url", .string, .required)
            .field("following_count", .int, .required)
            .field("followers_count", .int, .required)
//            .field("is_admin", .bool, .required, .custom("DEFAULT FALSE"))
//            .field("is_email_verified", .bool, .required, .custom("DEFAULT FALSE"))
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users").delete()
    }
}

