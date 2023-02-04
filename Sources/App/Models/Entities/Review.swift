import Vapor
import Fluent

final class Review: Model {
    static let schema = "reviews"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "text")
    var text: String
    
    @Field(key: "stars")
    var stars: Int
    
    init() {}
    
    init(id: UUID? = nil, userID: UUID, text: String, stars: Int) {
        self.id = id
        self.$user.id = userID
        self.text = text
        self.stars = stars
    }
}
