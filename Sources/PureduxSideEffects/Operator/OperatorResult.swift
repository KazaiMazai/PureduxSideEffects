//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

public enum OperatorResult<T> {
    case success(T)
    case cancelled
    case error(Error)
}
