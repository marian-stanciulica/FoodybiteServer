import Vapor
import Fluent

protocol ReviewRepository: Repository {
    func create(_ review: Review) -> EventLoopFuture<Void>
    func find(userID: UUID) -> EventLoopFuture<[Review]>
    func count() -> EventLoopFuture<Int>
}
