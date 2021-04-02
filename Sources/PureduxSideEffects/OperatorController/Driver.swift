//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import PureduxStore

public struct Driver<Operator, State, Action>
    where
    Operator: OperatorProtocol {

    public let store: Store<State, Action>

    private let sideEffectsOperator: Operator
    private let prepareInput: (_ state: State, _ on: Store<State, Action>) -> Operator.Input

    public init(store: Store<State, Action>,
                sideEffectsOperator: Operator,
                prepareInput: @escaping (State, Store<State, Action>) -> Operator.Input) {
        self.store = store
        self.sideEffectsOperator = sideEffectsOperator
        self.prepareInput = prepareInput
    }
}

extension Driver {
    public var asObserver: Observer<State> {
        Observer(queue: self.sideEffectsOperator.processingQueue) { state in
            self.observe(state: state)
            return .active
        }
    }
}

extension Driver {
    private func observe(state: State) {
        let operatorInput = prepareInput(state, store)
        self.sideEffectsOperator.process(operatorInput)
    }

}
