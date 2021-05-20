//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

public enum TaskResult<T> {
    case success(T)
    case cancelled
    case error(Error)
}
