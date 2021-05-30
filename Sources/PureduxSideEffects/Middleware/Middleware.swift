//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import PureduxStore
import Dispatch

public struct Middleware<State, Action, Operator>
    where
    Operator: OperatorProtocol {

    private let store: Store<State, Action>
    private let sideEffectsOperator: Operator

    private let props: (_ state: State, _ store: Store<State, Action>) -> Operator.Props

    public init(store: Store<State, Action>,
                operator: Operator,
                props: @escaping (State, Store<State, Action>) -> Operator.Props) {
        self.store = store
        self.sideEffectsOperator = `operator`
        self.props = props
    }

    public init(store: Store<State, Action>,
                operator: Operator,
                sideEffects: SideEffects<State, Action, Operator.Props>) {
        self.store = store
        self.sideEffectsOperator = `operator`
        self.props = sideEffects.props
    }
}

extension Middleware {
    public var asObserver: Observer<State> {
        Observer { state in
            sideEffectsOperator.processingQueue.async { observe(state: state) }
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
