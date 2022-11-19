import Vapor

struct LoginResponse: Content {
    let user: User.Public
    let token: AuthToken
}

struct AuthToken: Content {
    let accessToken: String
    let refreshToken: String
}
