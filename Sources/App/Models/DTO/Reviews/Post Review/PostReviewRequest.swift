import Vapor

struct PostReviewRequest: Content {
    let text: String
    let starsNumber: Int
}

extension PostReviewRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("starsNumber", as: Int.self, is: .range(1...5))
    }
}
