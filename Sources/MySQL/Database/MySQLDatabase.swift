/// Creates connections to an identified MySQL database.
public final class MySQLDatabase: Database {
    /// This database's configuration.
    public let config: MySQLDatabaseConfig

    /// If non-nil, will log queries.
    public var logger: DatabaseLogger?

    /// Creates a new `MySQLDatabase`.
    public init(config: MySQLDatabaseConfig) {
        self.config = config
    }

    /// See `Database`
    public func newConnection(on worker: Worker) -> Future<MySQLConnection> {
        let config = self.config
        return Future.flatMap(on: worker) {
            return try MySQLConnection.connect(hostname: config.hostname, port: config.port, on: worker) { error in
                print("[MySQL] \(error)")
            }.flatMap(to: MySQLConnection.self) { client in
                client.logger = self.logger
                return client.authenticate(
                    username: config.username,
                    database: config.database,
                    password: config.password
                ).transform(to: client)
            }.flatMap(to: MySQLConnection.self) { client in
                guard let timeZone = config.timeZone else {
                    return Future.done(on: worker).transform(to: client)
                }
                
                let seconds = timeZone.secondsFromGMT()
                let absHour: Int = abs(seconds) / 3600
                let absMin: Int = abs(seconds) % 3600 / 60
                let signStr: String = seconds >= 0 ? "+" : "-"
                let str: String = "\(signStr)\(absHour):\(absMin)"
                
                return client.simpleQuery("SET time_zone = '\(str)'")
                    .transform(to: client)
            }
        }
    }
}

extension DatabaseIdentifier {
    /// Default identifier for `MySQLDatabase`.
    public static var mysql: DatabaseIdentifier<MySQLDatabase> {
        return .init("mysql")
    }
}

