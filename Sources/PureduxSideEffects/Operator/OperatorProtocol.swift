//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.04.2021.
//

import Foundation

public protocol OperatorProtocol {
    associatedtype Props
    associatedtype Request: OperatorRequest
    associatedtype Task: OperatorTask

    var processingQueue: DispatchQueue { get }
    func process(_ props: Props)

    func createTaskFor(_ request: Request, with taskResultHandler: @escaping (TaskResult<Request.Result>) -> Void) -> Task

    func run(task: Task, for request: Request)
}
