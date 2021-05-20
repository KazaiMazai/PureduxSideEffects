//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

public protocol OperatorRequest {
    associatedtype Result
    associatedtype Status
    associatedtype RequestID: Hashable

    var id: RequestID { get }
    func handle(_ result: TaskResult<Result, Status>)
}
