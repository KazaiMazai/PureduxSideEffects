//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import PureduxStore
//
//public typealias Store<State, Action> = ReduxStore.Store<State, Action>
//public typealias Observer<State> = ReduxStore.Observer<State>

public protocol SideEffectsDriver {
    associatedtype State
    associatedtype Action

    var store: Store<State, Action> { get }

    var asObserver: Observer<State> { get }
}

public struct Driver<Operator, State, Action>
    where
    Operator: OperatorProtocol {

    public let store: Store<State, Action>
    private let sideEffectsOperator: Operator
    private let prepareRequests: (_ state: State, _ on: Store<State, Action>) -> [Operator.Request]

    private func observe(state: State) {
        let requests = prepareRequests(state, store)
        self.sideEffectsOperator.process(requests: requests)
    }

    public init(store: Store<State, Action>,
                sideEffectsOperator: Operator,
                prepareRequests: @escaping (State, Store<State, Action>) -> [Operator.Request]) {
        self.store = store
        self.sideEffectsOperator = sideEffectsOperator
        self.prepareRequests = prepareRequests
    }
}

extension Driver: SideEffectsDriver {
    public var asObserver: Observer<State> {
        Observer(queue: self.sideEffectsOperator.queue) { state in
            self.observe(state: state)
            return .active
        }
    }
}

