struct Constants {
    /// How long should refresh tokens live for: Default: 7 days (in seconds)
    static let REFRESH_TOKEN_LIFETIME: Double = 60 * 60 * 24 * 7
    
    /// How long should access tokens live for. Default: 15 minutes (in seconds)
    static let ACCESS_TOKEN_LIFETIME: Double = 60 * 15
}
