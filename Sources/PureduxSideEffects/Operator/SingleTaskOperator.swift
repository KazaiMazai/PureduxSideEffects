//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.04.2021.
//

import Foundation

open class SingleTaskOperator<Request, Task>: OperatorProtocol
    where
    Task: OperatorTask,
    Request: OperatorRequest {

    private let underlyingOperator: Operator<Request, Task>

    public var processingQueue: DispatchQueue { underlyingOperator.processingQueue }

    public init(label: String,
                qos: DispatchQoS,
                logSource: LogSource = .defaultLogging()) {
        underlyingOperator = Operator(label: label, qos: qos, logSource: logSource)
    }

    public func process(_ input: Request) {
        underlyingOperator.process([input])
    }

    open func createTaskFor(_ request: Request, with completeHandler: @escaping (OperatorResult<Request.Result>) -> Void) -> Task {
        fatalError("Not implemented. Should be overriden")
    }

    open func run(task: Task, for request: Request) {
        fatalError("Not implemented. Should be overriden")
    }
}
