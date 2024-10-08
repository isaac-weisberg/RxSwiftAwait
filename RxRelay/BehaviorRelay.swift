//
//  BehaviorRelay.swift
//  RxRelay
//
//  Created by Krunoslav Zaher on 10/7/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// BehaviorRelay is a wrapper for `BehaviorSubject`.
///
/// Unlike `BehaviorSubject` it can't terminate with error or completed.
public final class BehaviorRelay<Element: Sendable>: ObservableType {
    private let subject: BehaviorSubject<Element>

    #if VICIOUS_TRACING
        public func accept(
            _ event: Element,
            file: StaticString = #file,
            function: StaticString = #function,
            line: UInt = #line
        )
            async {
            await subject.onNext(event, C(file, function, line))
        }
    #else
        public func accept(_ event: Element) async {
            await subject.onNext(event, C())
        }
    #endif

    /// Accepts `event` and emits it to subscribers
    public func accept(_ event: Element, _ c: C) async {
        await subject.onNext(event, c.call())
    }

    /// Current value of behavior subject
    public var value: Element {
        // this try! is ok because subject can't error out or be disposed
        get async {
            try! await subject.value()
        }
    }

    /// Initializes behavior relay with initial value.
    public init(value: Element) {
        subject = BehaviorSubject(value: value)
    }

    /// Subscribes observer
    public func subscribe<Observer: ObserverType>(_ c: C, _ observer: Observer) async -> Disposable
        where Observer.Element == Element {
        await subject.subscribe(c.call(), observer)
    }

    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<Element> {
        subject.asObservable()
    }

    /// Convert to an `Infallible`
    ///
    /// - returns: `Infallible<Element>`
//    public func asInfallible() async -> Infallible<Element> {
//        await asInfallible(onErrorFallbackTo: .empty())
//    }
}
