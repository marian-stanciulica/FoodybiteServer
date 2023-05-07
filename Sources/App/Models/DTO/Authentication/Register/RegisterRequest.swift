import Vapor

struct RegisterRequest: Content {
    let name: String
    let email: String
    let password: String
    let profile_image: Data?
}

extension RegisterRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(3...))
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension User {
    convenience init(from register: RegisterRequest, hash: String) throws {
        self.init(email: register.email, password: hash, name: register.name, profileImage: register.profile_image)
    }
}
