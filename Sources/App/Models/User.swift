//
//  User.swift
//  
//
//  Created by Marian Stanciulica on 01.07.2022.
//

import Vapor
import Fluent

final class User: Model {
    static let schema = "user"

    @ID
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "profile_image")
    var profileImageURL: String?
    
    @OptionalField(key: "followers_count")
    var followersCount: Int?
    
    @OptionalField(key: "following_count")
    var followingCount: Int?

    init() {}

    init(id: UUID? = nil, email: String, password: String, name: String) {
        self.id = id
        self.email = email
        self.password = password
        self.name = name
        self.profileImageURL = ""
        self.followingCount = 0
        self.followersCount = 0
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var email: String
        var profileImageURL: String = ""
        var followingCount = 0
        var followersCount = 0
        
        init(id: UUID?, email: String, name: String) {
            self.id = id
            self.email = email
            self.name = name
        }
    }
    
}

extension User: Content { }

extension User.Public: Content {}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, email: email, name: name)
    }
}

extension EventLoopFuture where Value: User {
  func convertToPublic() -> EventLoopFuture<User.Public> {
    return self.map { user in
      return user.convertToPublic()
    }
  }
}

extension Collection where Element: User {
  func convertToPublic() -> [User.Public] {
    return self.map { $0.convertToPublic() }
  }
}

extension EventLoopFuture where Value == Array<User> {
  func convertToPublic() -> EventLoopFuture<[User.Public]> {
    return self.map { $0.convertToPublic() }
  }
}
