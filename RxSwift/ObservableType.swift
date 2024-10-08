//
//  ObservableType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents a push style sequence.
public protocol ObservableType: ObservableConvertibleType, Sendable {
    /**
     Subscribes `observer` to receive events for this sequence.

     ### Grammar

     **Next\* (Error | Completed)?**

     * sequences can produce zero or more elements so zero or more `Next` events can be sent to `observer`
     * once an `Error` or `Completed` event is sent, the sequence terminates and can't produce any other elements

     It is possible that events are sent from different threads, but no two events can be sent concurrently to
     `observer`.

     ### Resource Management

     When sequence sends `Complete` or `Error` event all internal resources that compute sequence elements
     will be freed.

     To cancel production of sequence elements and free resources immediately, call `dispose` on returned
     subscription.

     - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
     */
    func subscribe<Observer: ObserverType>(_ c: C, _ observer: Observer) async -> AsynchronousDisposable
        where Observer.Element == Element
}

//public protocol AsyncObservableToAsyncObserverType: AsyncObservableToAsyncObserverConvertibleType, Sendable {
//    func subscribe<Observer: AsyncObserverType>(_ c: C, _ observer: Observer) async -> AnyDisposable
//        where Observer.Element == Element
//}
//
//public protocol AsyncObservableToSyncObserverType: AsyncObservableToSyncObserverConvertibleType, Sendable {
//    func subscribe<Observer: SyncObserverType>(_ c: C, _ observer: Observer) async -> AnyDisposable
//        where Observer.Element == Element
//}

public extension ObservableType {

    /// Default implementation of converting `ObservableType` to `Observable`.
    func asObservable() -> Observable<Element> {
        // temporary workaround
        // return Observable.create(subscribe: self.subscribe)
        Observable<Element>.ccreate { c, o in await self.subscribe(c.call(), o) }
    }
}
//
//public protocol SyncObservableToAsyncObserverType: SyncObservableToAsyncObserverConvertibleType, Sendable {
//    func subscribe<Observer: AsyncObserverType>(_ c: C, _ observer: Observer) -> SynchronousDisposable
//        where Observer.Element == Element
//}
//
//public protocol SyncObservableToSyncObserverType: SyncObservableToSyncObserverConvertibleType, Sendable {
//    func subscribe<Observer: SyncObserverType>(_ c: C, _ observer: Observer) -> SynchronousDisposable
//        where Observer.Element == Element
//}
