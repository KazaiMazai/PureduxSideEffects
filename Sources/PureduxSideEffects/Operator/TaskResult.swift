//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

public enum TaskResult<T, Status> {
    case success(T)
    case cancelled
    case statusChanged(Status)
    case error(Error)
}
