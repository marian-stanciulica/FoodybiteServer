import Vapor

func services(_ app: Application) throws {
    app.repositories.use(.database)
    app.randomGenerators.use(.random)
}
