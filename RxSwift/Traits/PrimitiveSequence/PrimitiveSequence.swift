//
//  PrimitiveSequence.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/5/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation

/// Observable sequences containing 0 or 1 element.
public struct PrimitiveSequence<Trait, Element: Sendable> {
    let source: Observable<Element>

    init(raw: Observable<Element>) {
        source = raw
    }
}

/// Observable sequences containing 0 or 1 element
public protocol PrimitiveSequenceType: Sendable {
    /// Additional constraints
    associatedtype Trait

    /// Sequence element type
    associatedtype Element: Sendable

    // Converts `self` to primitive sequence.
    ///
    /// - returns: Observable sequence that represents `self`.
    var primitiveSequence: PrimitiveSequence<Trait, Element> { get }
}

extension PrimitiveSequence: PrimitiveSequenceType {
    // Converts `self` to primitive sequence.
    ///
    /// - returns: Observable sequence that represents `self`.
    public var primitiveSequence: PrimitiveSequence<Trait, Element> {
        self
    }
}

extension PrimitiveSequence: ObservableConvertibleType {
    /// Converts `self` to `Observable` sequence.
    ///
    /// - returns: Observable sequence that represents `self`.
    public func asObservable() -> Observable<Element> {
        source
    }
}

public extension PrimitiveSequence {
    /**
     Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.

     - seealso: [defer operator on reactivex.io](http://reactivex.io/documentation/operators/defer.html)

     - parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
     - returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
     */
    static func deferred(_ observableFactory: @escaping () async throws -> PrimitiveSequence<Trait, Element>)
        -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence(raw: Observable.deferred {
            try await observableFactory().asObservable()
        })
    }

    /**
     Returns an observable sequence by the source observable sequence shifted forward in time by a specified delay. Error events from the source observable sequence are not delayed.

     - seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)

     - parameter dueTime: Relative time shift of the source by.
     - parameter scheduler: Scheduler to run the subscription delay timer on.
     - returns: the source Observable shifted in time by the specified delay.
     */
    func delay(_ dueTime: RxTimeInterval)
        -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence(raw: primitiveSequence.source.delay(dueTime))
    }

    /**
     Time shifts the observable sequence by delaying the subscription with the specified relative time duration, using the specified scheduler to run timers.

     - seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)

     - parameter dueTime: Relative time shift of the subscription.
     - parameter scheduler: Scheduler to run the subscription delay timer on.
     - returns: Time-shifted sequence.
     */
    func delaySubscription(_ dueTime: RxTimeInterval)
        -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence(raw: source.delaySubscription(dueTime))
    }

    /**
     Wraps the source sequence in order to run its observer callbacks on the specified scheduler.

     This only invokes observer callbacks on a `scheduler`. In case the subscription and/or unsubscription
     actions have side-effects that require to be run on a scheduler, use `subscribeOn`.

     - seealso: [observeOn operator on reactivex.io](http://reactivex.io/documentation/operators/observeon.html)

     - parameter scheduler: Scheduler to notify observers on.
     - returns: The source sequence whose observations happen on the specified scheduler.
     */
    func observe(on scheduler: any AsyncScheduler)
        -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence(raw: source.observe(on: scheduler))
    }

    func subscribe(on scheduler: any AsyncScheduler)
        -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence(raw: source.subscribe(on: scheduler))
    }

    /**
     Continues an observable sequence that is terminated by an error with the observable sequence produced by the
     handler.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - parameter handler: Error handler function, producing another observable sequence.
     - returns: An observable sequence containing the source sequence's elements, followed by the elements produced by
     the handler's resulting observable sequence in case an error occurred.
     */
    func `catch`(_ handler: @escaping (Swift.Error) async throws -> PrimitiveSequence<Trait, Element>)
        -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence(raw: source.catch { try await handler($0).asObservable() })
    }

    /**
     If the initial subscription to the observable sequence emits an error event, try repeating it up to the specified number of attempts (inclusive of the initial attempt) or until is succeeds. For example, if you want to retry a sequence once upon failure, you should use retry(2) (once for the initial attempt, and once for the retry).

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter maxAttemptCount: Maximum number of times to attempt the sequence subscription.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully.
     */
//    func retry(_ maxAttemptCount: Int) async
//        -> PrimitiveSequence<Trait, Element>
//    {
//        await PrimitiveSequence(raw: self.source.retry(maxAttemptCount))
//    }

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
//    func retry<TriggerObservable: ObservableType, Error: Swift.Error>(when notificationHandler: @escaping
//    (Observable<Error>) -> TriggerObservable) async
//        -> PrimitiveSequence<Trait, Element>
//    {
//        await PrimitiveSequence(raw: self.source.retry(when: notificationHandler))
//    }

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
//    @available(*, deprecated, renamed: "retry(when:)")
//    func retryWhen<TriggerObservable: ObservableType, Error: Swift.Error>(_ notificationHandler: @escaping
//    (Observable<Error>) -> TriggerObservable) async
//        -> PrimitiveSequence<Trait, Element>
//    {
//        await self.retry(when: notificationHandler)
//    }

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
//    func retry<TriggerObservable: ObservableType>(when notificationHandler: @escaping (Observable<Swift.Error>) ->
//    TriggerObservable) async
//        -> PrimitiveSequence<Trait, Element>
//    {
//        await PrimitiveSequence(raw: self.source.retry(when: notificationHandler))
//    }

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
//    @available(*, deprecated, renamed: "retry(when:)")
//    func retryWhen<TriggerObservable: ObservableType>(_ notificationHandler: @escaping (Observable<Swift.Error>) ->
//    TriggerObservable) async
//        -> PrimitiveSequence<Trait, Element>
//    {
//        await self.retry(when: notificationHandler)
//    }

    /**
     Prints received events for all observers on standard output.

     - seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)

     - parameter identifier: Identifier that is printed together with event description to standard output.
     - parameter trimOutput: Should output be trimmed to max 40 characters.
     - returns: An observable sequence whose events are printed to standard output.
     */
    func debug(
        _ identifier: String? = nil,
        trimOutput: Bool = false,
        file: String = #file,
        line: UInt = #line,
        function: String = #function
    ) -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence(raw: source.debug(
            identifier,
            trimOutput: trimOutput,
            file: file,
            line: line,
            function: function
        ))
    }

    /**
     Constructs an observable sequence that depends on a resource object, whose lifetime is tied to the resulting observable sequence's lifetime.

     - seealso: [using operator on reactivex.io](http://reactivex.io/documentation/operators/using.html)

     - parameter resourceFactory: Factory function to obtain a resource object.
     - parameter primitiveSequenceFactory: Factory function to obtain an observable sequence that depends on the obtained resource.
     - returns: An observable sequence whose lifetime controls the lifetime of the dependent resource object.
     */
    static func using<Resource: Disposable>(
        _ resourceFactory: @escaping () async throws -> Resource,
        primitiveSequenceFactory: @escaping (Resource) async throws -> PrimitiveSequence<Trait, Element>
    )
        -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence(raw: Observable.using(
            resourceFactory,
            observableFactory: { (resource: Resource) throws -> Observable<Element> in
                try await primitiveSequenceFactory(resource).asObservable()
            }
        ))
    }

    /**
     Applies a timeout policy for each element in the observable sequence. If the next element isn't received within the specified timeout duration starting from its predecessor, a TimeoutError is propagated to the observer.

     - seealso: [timeout operator on reactivex.io](http://reactivex.io/documentation/operators/timeout.html)

     - parameter dueTime: Maximum duration between values before a timeout occurs.
     - parameter scheduler: Scheduler to run the timeout timer on.
     - returns: An observable sequence with a `RxError.timeout` in case of a timeout.
     */
    func timeout(_ dueTime: RxTimeInterval)
        -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence<Trait, Element>(raw: primitiveSequence.source.timeout(dueTime))
    }

    func timeout(_ dueTime: RxTimeInterval, scheduler: any AsyncScheduler)
        -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence<Trait, Element>(raw: primitiveSequence.source.timeout(dueTime, scheduler: scheduler))
    }

    func timeout(_ dueTime: RxTimeInterval, scheduler: any MainLegacySchedulerProtocol)
        -> PrimitiveSequenceObservedOnMainScheduler<Trait, ObserveOnMainActorObservable<Element>> {
        PrimitiveSequenceObservedOnMainScheduler(
            raw: primitiveSequence.source.timeout(dueTime, scheduler: scheduler)
        )
    }

    /**
     Applies a timeout policy for each element in the observable sequence, using the specified scheduler to run timeout timers. If the next element isn't received within the specified timeout duration starting from its predecessor, the other observable sequence is used to produce future messages from that point on.

     - seealso: [timeout operator on reactivex.io](http://reactivex.io/documentation/operators/timeout.html)

     - parameter dueTime: Maximum duration between values before a timeout occurs.
     - parameter other: Sequence to return in case of a timeout.
     - parameter scheduler: Scheduler to run the timeout timer on.
     - returns: The source sequence switching to the other sequence in case of a timeout.
     */
    func timeout(
        _ dueTime: RxTimeInterval,
        other: PrimitiveSequence<Trait, Element>
    ) -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence<Trait, Element>(raw: primitiveSequence.source.timeout(
            dueTime,
            other: other.source
        ))
    }

    func timeout(
        _ dueTime: RxTimeInterval,
        other: PrimitiveSequence<Trait, Element>,
        scheduler: any AsyncScheduler
    ) -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence<Trait, Element>(raw: primitiveSequence.source.timeout(
            dueTime,
            other: other.source,
            scheduler: scheduler
        ))
    }

    func timeout(
        _ dueTime: RxTimeInterval,
        other: PrimitiveSequence<Trait, Element>,
        scheduler: any MainLegacySchedulerProtocol
    ) -> PrimitiveSequenceObservedOnMainScheduler<Trait, ObserveOnMainActorObservable<Element>> {
        PrimitiveSequenceObservedOnMainScheduler(raw: primitiveSequence.source.timeout(
            dueTime,
            other: other.source,
            scheduler: scheduler
        ))
    }
}

public extension PrimitiveSequenceType where Element: RxAbstractInteger {
    /**
     Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.

     - seealso: [timer operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)

     - parameter dueTime: Relative time at which to produce the first value.
     - parameter scheduler: Scheduler to run timers on.
     - returns: An observable sequence that produces a value after due time has elapsed and then each period.
     */
    static func timer(_ dueTime: RxTimeInterval)
        -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence(raw: Observable<Element>.timer(dueTime))
    }
}

public struct PrimitiveSequenceObservedOnMainScheduler<Trait, Source: MainActorObservable> {
    public typealias Element = Source.Element
    public let source: Source

    public init(raw: Source) {
        source = raw
    }
}

public extension PrimitiveSequence {
    func observe(on scheduler: MainLegacySchedulerProtocol)
        -> PrimitiveSequenceObservedOnMainScheduler<Trait, ObserveOnMainActorObservable<
            Element
        >> {
        PrimitiveSequenceObservedOnMainScheduler(raw: source.observe(on: scheduler))
    }
}
