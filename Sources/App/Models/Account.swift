//
//  Account.swift
//  
//
//  Created by Marian Stanciulica on 01.07.2022.
//

import Vapor
import Fluent

final class Account: Model {
    static let schema = "account"

    @ID
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String

    init() {}

    init(id: UUID? = nil, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
}

extension Account: Content { }
