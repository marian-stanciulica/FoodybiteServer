import Vapor

extension Request {
    var users: UserRepository { application.repositories.users.for(self) }
    var refreshTokens: RefreshTokenRepository { application.repositories.refreshTokens.for(self) }
    var reviews: ReviewRepository { application.repositories.reviews.for(self) }
}
