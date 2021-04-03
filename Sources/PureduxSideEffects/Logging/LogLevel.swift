//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

public enum LogLevel: Int, Comparable {
    case trace
    case debug
    case info
    case notice
    case warning
    case error
    case critical
    case silent


    var label: String {
        switch self {
        case .trace:
            return "🔎"
        case .debug:
            return "🐞"
        case .info:
            return "ℹ️"
        case .notice:
            return "✋🏼"
        case .warning:
            return "⚠️"
        case .error:
            return "😡"
        case .critical:
            return "🔥"
        case .silent:
            return "🤐"
        }
    }
}

extension LogLevel {
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.level < rhs.level
    }
}

extension LogLevel {
    private var level: Int {
        rawValue
    }
}
