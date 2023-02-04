import Fluent

struct CreateReview: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("reviews")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("place_id", .string, .required)
            .field("text", .string, .required)
            .field("stars", .uint, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("reviews").delete()
    }
}
