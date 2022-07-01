import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.post("signup") { request -> EventLoopFuture<Account> in
        let account = try request.content.decode(Account.self)
        return account.save(on: request.db).map { account }
    }
    
}
