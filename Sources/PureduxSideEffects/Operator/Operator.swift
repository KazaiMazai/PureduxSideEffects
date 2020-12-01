//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation

public protocol OperatorProtocol {
    associatedtype Request: OperatorRequest
    associatedtype Task: OperatorTask

    var queue: DispatchQueue { get }
    func process(requests: [Request])

    func createTaskFor(_ request: Request, with completeHandler: @escaping (OperatorResult<Request.Result>) -> Void) -> Task

    func run(task: Task, for request: Request)
}

open class Operator<Request, Task>: OperatorProtocol where Task: OperatorTask, Request: OperatorRequest {
    private var activeRequests: [Request.RequestID: (Request, Task)] = [:]
    private var completedRequests: Set<Request.RequestID> = []

    public let queue: DispatchQueue
    public let logging: LogSource

    public init(queueLabel: String,
                qos: DispatchQoS,
                logging: LogSource = .defaultLogging()) {
        self.queue = DispatchQueue(label: queueLabel)
        self.logging = logging
    }

    public func process(requests: [Request]) {
        queue.async { [weak self] in
            self?.updateActiveRequests(requests: requests)
        }
    }

    open func createTaskFor(_ request: Request, with completeHandler: @escaping (OperatorResult<Request.Result>) -> Void) -> Task {
        fatalError("Not implemented. Should be overriden")
    }

    open func run(task: Task, for request: Request) {
        fatalError("Not implemented. Should be overriden")
    }
}

extension Operator {
    private func updateActiveRequests(requests: [Request]) {
        var remainedActiveRequestsIds = Set(activeRequests.keys)

        for request in requests {
            process(request: request)
            remainedActiveRequestsIds.remove(request.id)
        }

        for cancelledRequestId in remainedActiveRequestsIds {
            cancel(requestId: cancelledRequestId)
        }
    }

    private func process(request: Request) {
        if completedRequests.contains(request.id) {
            return
        }

        guard !activeRequests.keys.contains(request.id) else {
            return
        }

        logging.log(.trace, "ID: \(request.id)")

        let task = createTaskFor(request) { [weak self] result in
            self?.queue.async {
                self?.complete(request: request, result: result)
            }
        }

        activeRequests[request.id] = (request, task)
        run(task: task, for: request)
    }

    private func cancel(requestId: Request.RequestID) {
        guard let (request, task) = activeRequests[requestId] else {
           return
        }

        task.cancel() // Stop task execution
        activeRequests[requestId] = nil
        request.handle(.cancelled)
    }

    private func complete(request: Request, result: OperatorResult<Request.Result>) {
        activeRequests[request.id] = nil
        completedRequests.insert(request.id)
        request.handle(result)
    }
}
