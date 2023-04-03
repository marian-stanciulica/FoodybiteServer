import Vapor

struct PostReviewRequest: Content {
    let restaurantID: String
    let text: String
    let stars: Int
    let createdAt: Date
}

extension PostReviewRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("stars", as: Int.self, is: .range(1...5))
    }
}
