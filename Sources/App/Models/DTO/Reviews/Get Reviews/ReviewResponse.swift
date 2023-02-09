import Vapor

struct ReviewResponse: Content {
    let placeID: String
    let profileImageData: Data?
    let authorName: String
    let reviewText: String
    let rating: Int
    let createdAt: Date
}
