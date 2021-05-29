//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29.05.2021.
//

import Foundation

public struct SideEffects<State, Action, Props> {
    public let props: (_ state: State, _ store: Store<State, Action>) -> [Props]

    public init(props: @escaping (_ state: State, _ store: Store<State, Action>) -> [Props]) {
        self.props = props
    }
}

extension SideEffects {

    static func && (lhs: SideEffects<State, Action, Props>, rhs: SideEffects<State, Action, Props>) -> SideEffects<State, Action, Props> {

        SideEffects<State, Action, Props> { state, store in
            [lhs.props(state, store), rhs.props(state, store)].flatMap { $0 }
        }
    }

    static func empty() -> SideEffects<State, Action, Props> {
        SideEffects<State, Action, Props> { _, _ in
            []
        }
    }

    static func compound<S>(_ sequence: S) -> SideEffects<State, Action, Props>
        where
        S: Sequence,
        S.Element == SideEffects<State, Action, Props> {

        return sequence.reduce(.empty(), &&)
    }

    static func conditional(
        condition: (State) -> Bool,
        then lhs: SideEffects<State, Action, Props>,
        else rhs: SideEffects<State, Action, Props>) -> SideEffects<State, Action, Props> {

        SideEffects<State, Action, Props> { state, store in
            condition(state) ?
                lhs(state, store)
                : rhs(state, store)
        }
    }
}
