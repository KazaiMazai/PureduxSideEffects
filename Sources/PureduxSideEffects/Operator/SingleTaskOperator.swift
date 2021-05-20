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
                logger: Logger = .console(.info)) {
        underlyingOperator = Operator(label: label, qos: qos, logger: logger)
    }

    public func process(_ input: Request?) {
        let processRequests = input.map { [$0] } ?? []
        underlyingOperator.process(processRequests)
    }

    open func createTaskFor(_ request: Request, with taskResultHandler: @escaping (TaskResult<Request.Result, Request.Status>) -> Void) -> Task {
        fatalError("Not implemented. Should be overriden")
    }

    open func run(task: Task, for request: Request) {
        fatalError("Not implemented. Should be overriden")
    }
}
