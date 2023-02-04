import Vapor
import Fluent

struct DatabaseReviewRepository: ReviewRepository, DatabaseRepository {
    let database: Database
    
    func create(_ review: Review) -> EventLoopFuture<Void> {
        return review.create(on: database)
    }
    
    func find(userID: UUID) -> EventLoopFuture<[Review]> {
        Review.query(on: database)
            .filter(\.$user.$id == userID)
            .all()
    }
    
    func count() -> EventLoopFuture<Int> {
        return Review.query(on: database).count()
    }
}

extension Application.Repositories {
    var reviews: RefreshTokenRepository {
        guard let factory = storage.makeRefreshTokenRepository else {
            fatalError("RefreshToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }
    
    func use(_ make: @escaping (Application) -> (ReviewRepository)) {
        storage.makeReviewRepository = make
    }
}
