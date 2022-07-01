//
//  CreateAccount.swift
//  
//
//  Created by Marian Stanciulica on 01.07.2022.
//

import Fluent

struct CreateAccount: Migration {
  
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("account")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("account").delete()
    }
    
}
