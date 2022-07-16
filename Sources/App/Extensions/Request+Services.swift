import Vapor

extension Request {
    var users: UserRepository { application.repositories.users.for(self) }
}
