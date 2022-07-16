import Vapor

struct LoginResponse: Content {
    let user: User.Public
    let accessToken: String
    let refreshToken: String
}
