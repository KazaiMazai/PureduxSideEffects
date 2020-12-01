//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

public protocol Logger {
    var level: Loglevel { get }
    func log<T>(_ level: Loglevel, _ msg: T)
}

public struct ConsoleLogger: Logger {
    public init(level: Loglevel) {
        self.level = level
    }

    public let level: Loglevel

    public func log<T>(_ level: Loglevel, _ msg: T) {
        guard level >= self.level else {
            return
        }
        print("[\(level.label)]", msg)
    }
}
