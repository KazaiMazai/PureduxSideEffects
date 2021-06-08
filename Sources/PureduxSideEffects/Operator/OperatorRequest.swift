//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

public protocol OperatorRequest {
    associatedtype SuccessResult
    associatedtype TaskStatus
    associatedtype ID: Hashable

    var id: ID { get }
    func handle(_ result: TaskResult<SuccessResult, TaskStatus>)
}
