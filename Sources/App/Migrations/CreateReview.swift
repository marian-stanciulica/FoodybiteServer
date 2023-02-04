import Fluent

struct CreateReview: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("reviews")
            .id()
            .field("user_id", .uuid, .references("users", "id", onDelete: .cascade))
            .field("text", .string)
            .field("stars", .int8)
            .unique(on: "user_id")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("reviews").delete()
    }
}
