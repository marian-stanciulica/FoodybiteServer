//
//  CreateAccount.swift
//  
//
//  Created by Marian Stanciulica on 01.07.2022.
//

import Fluent

struct CreateUser: Migration {
  
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("password", .string, .required)
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("account").delete()
    }
    
}

