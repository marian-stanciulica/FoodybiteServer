import Fluent
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) throws {
    // MARK: JWT
    if app.environment != .testing {
//        let jwksFilePath = app.directory.workingDirectory + (Environment.get("JWKS_KEYPAIR_FILE") ?? "keypair.jwks")
//         guard
//             let jwks = FileManager.default.contents(atPath: jwksFilePath),
//             let jwksString = String(data: jwks, encoding: .utf8)
//             else {
//                 fatalError("Failed to load JWKS Keypair file at: \(jwksFilePath)")
//         }
        app.jwt.signers.use(.hs256(key: "secret"))
    }
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateRefreshToken())
    
    app.logger.logLevel = .debug
    try app.autoMigrate().wait()
    
    try services(app)
    try routes(app)
}
