import Vapor

struct PostReviewRequest: Content {
    let placeID: String
    let text: String
    let stars: Int
}

extension PostReviewRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("stars", as: Int.self, is: .range(1...5))
    }
}
