//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

open class Operator<Request, Task>: OperatorProtocol
    where
    Task: OperatorTask,
    Request: OperatorRequest {

    private var activeRequests: [Request.RequestID: (Request, Task)] = [:]
    private var completedRequests: Set<Request.RequestID> = []

    public let processingQueue: DispatchQueue
    public let logger: Logger

    public init(label: String,
                qos: DispatchQoS,
                logger: Logger = .console(.info)) {
        self.processingQueue = DispatchQueue(label: label)
        self.logger = .with(label: label, logger: logger)
    }

    public func process(_ input: [Request]) {
        processingQueue.async { [weak self] in
            self?.performTasksFor(input)
        }
    }

    open func createTaskFor(_ request: Request, with taskResultHandler: @escaping (TaskResult<Request.Result>) -> Void) -> Task {
        fatalError("Not implemented. Should be overriden")
    }

    open func run(task: Task, for request: Request) {
        fatalError("Not implemented. Should be overriden")
    }
}

extension Operator {
    private func performTasksFor(_ requests: [Request]) {
        var requestsToCancel = Set(activeRequests.keys)

        requests.forEach {
            runTaskIfNeededFor($0)
            requestsToCancel.remove($0.id)
        }

        requestsToCancel.forEach {
            cancel(requestId: $0)
        }
    }

    private func runTaskIfNeededFor(_ request: Request) {
        if completedRequests.contains(request.id) {
            return
        }

        guard !activeRequests.keys.contains(request.id) else {
            return
        }

        logger.log(.debug, "[Run] ID: \(request.id)")

        let task = createTaskFor(request) { [weak self] result in
            self?.processingQueue.async {
                self?.complete(request: request, with: result)
            }
        }

        activeRequests[request.id] = (request, task)
        run(task: task, for: request)
    }

    private func cancel(requestId: Request.RequestID) {
        guard let (request, task) = activeRequests[requestId] else {
           return
        }

        logger.log(.debug, "[Cancel] ID: \(requestId)")
        task.cancel()
        activeRequests[requestId] = nil
        request.handle(.cancelled)
    }

    private func complete(request: Request, with result: TaskResult<Request.Result>) {
        logger.log(.debug, "[Complete] ID: \(request.id)")
        activeRequests[request.id] = nil
        completedRequests.insert(request.id)
        request.handle(result)
    }
}
