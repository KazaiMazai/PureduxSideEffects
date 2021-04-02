//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import PureduxStore

public struct Middleware<State, Action, Operator>
    where
    Operator: OperatorProtocol {

    public let store: Store<State, Action>

    private let sideEffectsOperator: Operator
    private let props: (_ state: State, _ on: Store<State, Action>) -> Operator.Props

    public init(store: Store<State, Action>,
                sideEffectsOperator: Operator,
                props: @escaping (State, Store<State, Action>) -> Operator.Props) {
        self.store = store
        self.sideEffectsOperator = sideEffectsOperator
        self.props = props
    }
}

extension Middleware {
    public var asObserver: Observer<State> {
        Observer(queue: self.sideEffectsOperator.processingQueue) { state in
            observe(state: state)
            return .active
        }
    }
}

extension Middleware {
    private func observe(state: State) {
        let operatorProps = props(state, store)
        sideEffectsOperator.process(operatorProps)
    }
}
