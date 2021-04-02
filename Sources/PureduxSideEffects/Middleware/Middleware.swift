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

    private let store: Store<State, Action>
    private let `operator`: Operator

    private let props: (_ state: State, _ store: Store<State, Action>) -> Operator.Props

    public init(store: Store<State, Action>,
                operator: Operator,
                props: @escaping (State, Store<State, Action>) -> Operator.Props) {
        self.store = store
        self.operator = `operator`
        self.props = props
    }
}

extension Middleware {
    public var asObserver: Observer<State> {
        Observer(queue: self.operator.processingQueue) {
            observe(state: $0)
            return .active
        }
    }
}

extension Middleware {
    private func observe(state: State) {
        let operatorProps = props(state, store)
        `operator`.process(operatorProps)
    }
}
