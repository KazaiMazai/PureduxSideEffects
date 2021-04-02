//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

public struct LogSource {
    private let name: String
    private let logger: Logger
    private let logLevel: LogLevel

    public init(name: String, logger: Logger, logLevel: LogLevel) {
        self.name = name
        self.logger = logger
        self.logLevel = logLevel
    }

    public static func defaultLogSource(logLevel: LogLevel = .info) -> LogSource {
        LogSource(name: "📱",
                  logger: ConsoleLogger(logLevel: logLevel),
                  logLevel: logLevel)
    }

    public func log<T>(_ level: LogLevel, _ msg: T) {
        guard level >= logLevel else {
            return
        }
        logger.log(level, "[\(name)] \(msg)")
    }

    public func log<T>(_ level: LogLevel, msg: T, with data: Data) {
        guard level >= logLevel else {
            return
        }
        let dataMsg = String(data: data, encoding: .utf8)
        logger.log(level, "[\(name)] \(msg) \(dataMsg ?? "No Data")")
    }
}
