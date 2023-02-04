import Vapor

struct ReviewResponse: Content {
    let profileImageData: Data?
    let authorName: String
    let reviewText: String
    let rating: Int
    let createdAt: Date
}
