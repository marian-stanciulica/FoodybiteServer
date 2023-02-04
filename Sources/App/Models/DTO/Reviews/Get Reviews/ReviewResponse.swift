import Vapor

struct ReviewResponse: Content {
    let text: String
    let stars: Int
}
