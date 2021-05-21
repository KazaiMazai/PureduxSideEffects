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

    private var activeRequests: [Request.ID: (Request, Task)] = [:]
    private var completedRequests: Set<Request.ID> = []

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

    open func createTaskFor(_ request: Request, with taskResultHandler: @escaping (TaskResult<Request.SuccessResult, Request.TaskStatus>) -> Void) -> Task {
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
            runTaskIfNeededFor(request: $0)
            requestsToCancel.remove($0.id)
        }

        requestsToCancel.forEach {
            cancel(requestId: $0)
        }
    }

    private func runTaskIfNeededFor(request: Request) {
        guard !completedRequests.contains(request.id) else {
            return
        }

        guard !activeRequests.keys.contains(request.id) else {
            return
        }

        logger.log(.debug, "[Run] ID: \(request.id)")

        let task = createTaskFor(request) { [weak self] result in
            self?.processingQueue.async {
                self?.handleTaskStatusUpdate(request: request, with: result)
            }
        }

        activeRequests[request.id] = (request, task)
        run(task: task, for: request)
    }

    private func cancel(requestId: Request.ID) {
        guard let (request, task) = activeRequests[requestId] else {
            return
        }

        logger.log(.debug, "[Cancel] ID: \(requestId)")
        task.cancel()
        activeRequests[requestId] = nil
        request.handle(.cancelled)
    }

    private func handleTaskStatusUpdate(request: Request, with result: TaskResult<Request.SuccessResult, Request.TaskStatus>) {
        switch result {
        case .success, .cancelled, .failure:
            logger.log(.debug, "[Complete] ID: \(request.id)")
            activeRequests[request.id] = nil
            completedRequests.insert(request.id)
        case .statusChanged(let status):
            logger.log(.debug, "[Status Changed] ID: \(request.id) [\(status)]")
            break
        }

        request.handle(result)
    }
}
