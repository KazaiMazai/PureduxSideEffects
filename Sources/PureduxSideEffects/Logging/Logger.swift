//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

public struct Logger {
    typealias LogHandler<T> = (_ level: LogLevel, _ msg: T) -> Void

    private let logLevel: LogLevel
    private let logHandler: LogHandler<Any>

    public init(logLevel: LogLevel, logHandler: Logger.LogHandler<Any>) {
        self.logLevel = logLevel
        self.logHandler = logHandler
    }

    public func log<T>(_ level: LogLevel, _ msg: T) {
        guard level >= logLevel else {
            return
        }

        logHandler(level, msg)
    }

    public func log<T>(_ level: LogLevel, msg: T, with data: Data) {
        guard level >= logLevel else {
            return
        }

        log(level, "\(msg) \(data.toPrettyString ?? "No Data")")
    }
}

public extension Logger {
    static var silent: Logger {
        Logger(logLevel: .silent) { _, _ in  }
    }

    static func console(_ logLevel: LogLevel) -> Logger {
        Logger(logLevel: logLevel) { level, msg in
            print("[\(level.label)]", msg)
        }
    }

    static func with(label: String, logLevel: LogLevel, logger: Logger) -> Logger {
        Logger(logLevel: logLevel) { level, msg in
            logger.log(level, "[\(label)] \(msg)")
        }
    }

    static func with(logLevel: LogLevel, logger: Logger) -> Logger {
        Logger(logLevel: logLevel) { level, msg in
            logger.log(level, msg)
        }
    }

    static func with(label: String, logger: Logger) -> Logger {
        .with(label: label, logLevel: logger.logLevel, logger: logger)
    }
}

fileprivate extension Data {
    var toPrettyString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyString = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        return prettyString
    }
}
