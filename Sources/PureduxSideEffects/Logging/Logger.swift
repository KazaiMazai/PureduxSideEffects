//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

public protocol Logger {
    var logLevel: LogLevel { get }
    func log<T>(_ level: LogLevel, _ msg: T)
}

public struct ConsoleLogger: Logger {
    public init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }

    public let logLevel: LogLevel

    public func log<T>(_ level: LogLevel, _ msg: T) {
        guard level >= self.level else {
            return
        }
        print("[\(level.label)]", msg)
    }
}
