//
//  User.swift
//  
//
//  Created by Marian Stanciulica on 01.07.2022.
//

import Vapor
import Fluent

final class User: Model, Authenticatable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var password: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "profile_image")
    var profileImage: Data?
    
    @Children(for: \.$user)
    var reviews: [Review]

    init() {}

    init(id: UUID? = nil, email: String, password: String, name: String, profileImage: Data?) {
        self.id = id
        self.email = email
        self.password = password
        self.name = name
        self.profileImage = profileImage
    }
    
    final class Public: Content {
        var id: UUID?
        var name: String
        var email: String
        var profileImage: Data?
        
        init(id: UUID?, email: String, name: String, profileImage: Data?) {
            self.id = id
            self.email = email
            self.name = name
            self.profileImage = profileImage
        }
    }
    
}

extension User {
    func asPublic() -> Public {
        return Public(id: id, email: email, name: name, profileImage: profileImage)
    }
}

