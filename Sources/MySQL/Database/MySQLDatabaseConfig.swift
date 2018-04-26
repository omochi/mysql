import Foundation

/// Config options for a `MySQLDatabase`
public struct MySQLDatabaseConfig {
    /// Creates a `MySQLDatabaseConfig` with default settings.
    public static func root(database: String) throws -> MySQLDatabaseConfig {
        return try .init(hostname: "127.0.0.1", port: 3306, username: "root", database: database)
    }

    /// Destination hostname.
    public let hostname: String

    /// Destination port.
    public let port: Int

    /// Username to authenticate.
    public let username: String

    /// Optional password to use for authentication.
    public let password: String?

    /// Database name.
    public let database: String

    /// Character set. Default utf8_general_ci
    public let characterSet: MySQLCharacterSet

    /// Connection timezone
    public let timeZone: TimeZone?
    
    /// Creates a new `MySQLDatabaseConfig`.
    public init(hostname: String = "127.0.0.1",
                port: Int = 3306,
                username: String,
                password: String? = nil,
                database: String,
                characterSet: String = "utf8_general_ci",
                timeZone: TimeZone? = nil) throws
    {
        guard let charSet = MySQLCharacterSet(string: characterSet) else {
            throw MySQLError(identifier: "invalidCharacterSet", reason: "Cannot initialize \(MySQLCharacterSet.self) with value \(characterSet).", source: .capture())
        }
        
        self.hostname = hostname
        self.port = port
        self.username = username
        self.database = database
        self.password = password
        self.characterSet = charSet
        self.timeZone = timeZone
    }
}
