//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29.05.2021.
//

import PureduxStore
import Foundation

public struct SideEffects<State, Action, Props> {
    public let props: (_ state: State, _ store: Store<State, Action>) -> Props

    public init(props: @escaping (_ state: State, _ store: Store<State, Action>) -> Props) {
        self.props = props
    }
}

public extension SideEffects where Props: Collection {
    static func + (lhs: SideEffects<State, Action, Props>, rhs: SideEffects<State, Action, Props>) -> SideEffects<State, Action, [Props.Element]> {

        SideEffects<State, Action, [Props.Element]> { state, store in
            [lhs.props(state, store), rhs.props(state, store)].flatMap { $0 }
        }
    }

    static var empty: SideEffects<State, Action, [Props.Element]> {
        SideEffects<State, Action, [Props.Element]> { _, _ in
            []
        }
    }

    var first: SideEffects<State, Action, Props.Element?> {
        SideEffects<State, Action, Props.Element?> { state, store in
            props(state, store).first
        }
    }
}

public extension Collection {
    func flatten<State, Action, Props>() -> SideEffects<State, Action, [Props]>

        where
        Element == SideEffects<State, Action, [Props]> {

        reduce(.empty, +)
    }

    func flatten<State, Action, Props>() -> SideEffects<State, Action, [Props]>

        where
        Element == SideEffects<State, Action, Props> {

        reduce(.empty, +)
    }
}

public extension Collection {
    func compactMap<State, Action, Props, T>(
        _ transform: @escaping (Props?) -> T?) -> SideEffects<State, Action, [T]>

        where
        Element == SideEffects<State, Action, Props?> {

        flatten().map { props in props.compactMap { transform($0) } }
    }

    func flatMap<State, Action, Props, ResultProps>(
        _ transform: @escaping (Props) -> ResultProps) -> SideEffects<State, Action, [ResultProps]>

        where
        Element == SideEffects<State, Action, [Props]> {

        flatten().map { props in props.compactMap { transform($0) } }
    }
}

public extension SideEffects {
    func map<T>(_ transform: @escaping (Props) -> T) -> SideEffects<State, Action, T> {
        SideEffects<State, Action, T> { state, store in
            transform(props(state, store))
        }
    }
}

public extension SideEffects {
    static var empty: SideEffects<State, Action, Props?> {
        SideEffects<State, Action, Props?> { _, _ in
            nil
        }
    }

    static func + (lhs: SideEffects<State, Action, [Props]>,
                   rhs: SideEffects<State, Action, Props>) -> SideEffects<State, Action, [Props]> {

        lhs + rhs.map { [$0] }
    }

    static func `if`(
        _ condition: @escaping (State) -> Bool,
        then sideEffects: SideEffects<State, Action, Props>,
        else optionalSideEffects: SideEffects<State, Action, Props>? = nil) -> SideEffects<State, Action, Props?> {

        SideEffects<State, Action, Props?> { state, store in
            condition(state) ?
                sideEffects.props(state, store)
                : optionalSideEffects?.props(state, store)
        }
    }
}
