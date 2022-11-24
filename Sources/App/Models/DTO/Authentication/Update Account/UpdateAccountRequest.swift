//
//  UpdateAccountRequest.swift
//  
//
//  Created by Marian Stanciulica on 24.11.2022.
//

import Vapor

struct UpdateAccountRequest: Content {
    let name: String
    let email: String
    let profileImage: Data?
}

extension UpdateAccountRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(3...))
        validations.add("email", as: String.self, is: .email)
    }
}
