import Vapor

struct ChangePasswordRequest: Content {
    let currentPassword: String
    let newPassword: String
}

extension ChangePasswordRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("currentPassword", as: String.self, is: .count(8...))
        validations.add("newPassword", as: String.self, is: .count(8...))
    }
}
