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

    public typealias TaskResultHandler = (TaskResult<Request.SuccessResult, Request.TaskStatus>) -> Void

    private lazy var underlyingOperator: ComposableOperator<Request, Task> = {
        ComposableOperator(
            label: label,
            qos: qos,
            logger: logger,
            createTask: createTaskFor,
            runTask: run)
    }()

    private let label: String
    private let qos: DispatchQoS
    private let logger: Logger

    public var processingQueue: DispatchQueue { underlyingOperator.processingQueue }

    public init(label: String,
                qos: DispatchQoS,
                logger: Logger = .console(.info)) {
        self.label = label
        self.qos = qos
        self.logger = logger
    }

    public func process(_ input: Request?) {
        let processRequests = input.map { [$0] } ?? []
        underlyingOperator.process(processRequests)
    }

    open func createTaskFor(_ request: Request,
                            with taskResultHandler: @escaping TaskResultHandler) -> Task {
        fatalError("Not implemented. Should be overriden")
    }

    open func run(task: Task, for request: Request) {
        fatalError("Not implemented. Should be overriden")
    }
}

private extension SingleTaskOperator {
    final class ComposableOperator<Request, Task>: Operator<Request, Task>
        where
        Task: OperatorTask,
        Request: OperatorRequest {

        typealias CreateTaskClosure = (Request, @escaping TaskResultHandler) -> Task
        typealias RunTaskClosure = (Task, Request) -> Void

        private let createTask: CreateTaskClosure
        private let runTask: RunTaskClosure

        init(label: String,
             qos: DispatchQoS,
             logger: Logger = .console(.info),
             createTask: @escaping CreateTaskClosure,
             runTask: @escaping RunTaskClosure) {

            self.createTask = createTask
            self.runTask = runTask
            super.init(label: label, qos: qos, logger: logger)
        }

        override func createTaskFor(_ request: Request,
                                          with taskResultHandler: @escaping TaskResultHandler) -> Task {
            createTask(request, taskResultHandler)
        }

        override func run(task: Task, for request: Request) {
            runTask(task, request)
        }
    }
}
