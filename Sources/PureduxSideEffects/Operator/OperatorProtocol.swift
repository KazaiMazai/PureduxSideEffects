//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.04.2021.
//

import Foundation

public protocol OperatorProtocol {
    associatedtype Input
    associatedtype Request: OperatorRequest
    associatedtype Task: OperatorTask

    var processingQueue: DispatchQueue { get }
    func process(_ input: Input)

    func createTaskFor(_ request: Request, with completeHandler: @escaping (OperatorResult<Request.Result>) -> Void) -> Task

    func run(task: Task, for request: Request)
}
