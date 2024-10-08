//
//  Error.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Returns an observable sequence that terminates with an `error`.

     - seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: The observable sequence that terminates with specified error.
     */
    static func error(_ error: Swift.Error) -> Observable<Element> {
        ErrorProducer(error: error)
    }
}

private final class ErrorProducer<Element: Sendable>: Producer<Element> {
    private let error: Swift.Error

    init(error: Swift.Error) {
        self.error = error
        super.init()
    }

    override func subscribe<Observer: ObserverType>(_ c: C, _ observer: Observer) async -> AsynchronousDisposable where Observer.Element == Element {
        await observer.on(.error(self.error), c.call())
        return Disposables.create()
    }
}
