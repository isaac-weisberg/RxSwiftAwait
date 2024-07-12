//
//  SkipUntil.swift
//  RxSwift
//
//  Created by Yury Korolev on 10/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Returns the elements from the source observable sequence that are emitted after the other observable sequence produces an element.

     - seealso: [skipUntil operator on reactivex.io](http://reactivex.io/documentation/operators/skipuntil.html)

     - parameter other: Observable sequence that starts propagation of elements of the source sequence.
     - returns: An observable sequence containing the elements of the source sequence that are emitted after the other sequence emits an item.
     */
    func skip<Source: ObservableType>(until other: Source)
        -> Observable<Element>
    {
        SkipUntil(source: self.asObservable(), other: other.asObservable())
    }

    /**
     Returns the elements from the source observable sequence that are emitted after the other observable sequence produces an element.

     - seealso: [skipUntil operator on reactivex.io](http://reactivex.io/documentation/operators/skipuntil.html)

     - parameter other: Observable sequence that starts propagation of elements of the source sequence.
     - returns: An observable sequence containing the elements of the source sequence that are emitted after the other sequence emits an item.
     */
    @available(*, deprecated, renamed: "skip(until:)")
    func skipUntil<Source: ObservableType>(_ other: Source)
        -> Observable<Element>
    {
        self.skip(until: other)
    }
}

private final class SkipUntilSinkOther<Other, Observer: ObserverType>:
    ObserverType,
    LockOwnerType,
    SynchronizedOnType
{
    typealias Parent = SkipUntilSink<Other, Observer>
    typealias Element = Other

    private let parent: Parent

    var lock: RecursiveLock {
        self.parent.lock
    }

    let subscription: SingleAssignmentDisposable

    init(parent: Parent) async {
        self.parent = parent
        self.subscription = await SingleAssignmentDisposable()
        #if TRACE_RESOURCES
            _ = await Resources.incrementTotal()
        #endif
    }

    func on(_ event: Event<Element>) async {
        await self.synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) async {
        switch event {
        case .next:
            self.parent.forwardElements = true
            await self.subscription.dispose()
        case .error(let e):
            await self.parent.forwardOn(.error(e))
            await self.parent.dispose()
        case .completed:
            await self.subscription.dispose()
        }
    }

    #if TRACE_RESOURCES
        deinit {
            Task {
                _ = await Resources.decrementTotal()
            }
        }
    #endif
}

private final class SkipUntilSink<Other, Observer: ObserverType>:
    Sink<Observer>,
    ObserverType,
    LockOwnerType,
    SynchronizedOnType
{
    typealias Element = Observer.Element
    typealias Parent = SkipUntil<Element, Other>

    let lock: RecursiveLock
    private let parent: Parent
    fileprivate var forwardElements = false

    private let sourceSubscription: SingleAssignmentDisposable

    init(parent: Parent, observer: Observer, cancel: Cancelable) async {
        self.sourceSubscription = await SingleAssignmentDisposable()
        self.parent = parent
        self.lock = await RecursiveLock()
        await super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<Element>) async {
        await self.synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) async {
        switch event {
        case .next:
            if self.forwardElements {
                await self.forwardOn(event)
            }
        case .error:
            await self.forwardOn(event)
            await self.dispose()
        case .completed:
            if self.forwardElements {
                await self.forwardOn(event)
            }
            await self.dispose()
        }
    }

    func run() async -> Disposable {
        let sourceSubscription = await self.parent.source.subscribe(self)
        let otherObserver = await SkipUntilSinkOther(parent: self)
        let otherSubscription = await self.parent.other.subscribe(otherObserver)
        await self.sourceSubscription.setDisposable(sourceSubscription)
        await otherObserver.subscription.setDisposable(otherSubscription)

        return await Disposables.create(sourceSubscription, otherObserver.subscription)
    }
}

private final class SkipUntil<Element, Other>: Producer<Element> {
    fileprivate let source: Observable<Element>
    fileprivate let other: Observable<Other>

    init(source: Observable<Element>, other: Observable<Other>) async {
        self.source = source
        self.other = other
        await super.init()
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) async -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = await SkipUntilSink(parent: self, observer: observer, cancel: cancel)
        let subscription = await sink.run()
        return (sink: sink, subscription: subscription)
    }
}
