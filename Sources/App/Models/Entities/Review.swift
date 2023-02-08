import Vapor
import Fluent

final class Review: Model {
    static let schema = "reviews"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "place_id")
    var placeID: String
    
    @Field(key: "text")
    var text: String
    
    @Field(key: "stars")
    var stars: Int
    
    @Field(key: "created_at")
    var createdAt: Date
    
    init() {}
    
    init(id: UUID? = nil, userID: UUID, placeID: String, text: String, stars: Int, createdAt: Date) {
        self.id = id
        self.$user.id = userID
        self.placeID = placeID
        self.text = text
        self.stars = stars
        self.createdAt = createdAt
    }
}
