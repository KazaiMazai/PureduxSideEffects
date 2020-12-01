//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

public struct LogSource {
    let name: String
    let logger: Logger
    let logLevel: Loglevel

    public init(name: String, logger: Logger, logLevel: Loglevel) {
        self.name = name
        self.logger = logger
        self.logLevel = logLevel
    }

    public static func defaultLogging(level: Loglevel = .info) -> LogSource {
        .init(name: "", logger: ConsoleLogger(level: level), logLevel: level)
    }

    public func log<T>(_ level: Loglevel, _ msg: T) {
        guard level >= self.logLevel else {
            return
        }
        logger.log(level, "[\(name)] \(msg)")
    }

    public func log<T>(_ level: Loglevel, msg: T, with data: Data) {
        guard level >= self.logLevel else {
            return
        }
        let dataMsg = String(data: data, encoding: .utf8)
        logger.log(level, "[\(name)] \(msg) \(dataMsg ?? "No Data")")
    }
}
