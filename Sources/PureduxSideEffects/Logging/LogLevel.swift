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
    case warning
    case error
    case silent

    var label: String {
        switch self {
        case .trace:
            return "🔎"
        case .debug:
            return "🐞"
        case .info:
            return "✏️"
        case .warning:
            return "✋🏼"
        case .error:
            return "😡"
        case .silent:
            return "🤐"
        }
    }

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
