public extension ObservableConvertibleType {
    func observe(on scheduler: AsyncScheduler) -> Observable<Element> {
        ObserveOn<Element>(scheduler: scheduler, source: asObservable())
    }
}

final class ObserveOn<Element: Sendable>: Observable<Element> {
    let scheduler: AsyncScheduler
    let source: Observable<Element>

    init(scheduler: AsyncScheduler, source: Observable<Element>) {
        self.scheduler = scheduler
        self.source = source
    }

    override public func subscribe<Observer: AsyncObserverType>(
        _ c: C,
        _ observer: Observer
    )
        async -> AsynchronousDisposable
        where Observer.Element == Element {
        let sink = ObserveOnSink(scheduler: scheduler, observer: observer)
        await sink.run(c.call(), source)
        return sink
    }
}

// public extension SubscribeToSyncCallType {
//    func observe<Scheduler: ActorScheduler>(on scheduler: Scheduler) -> ObserveOnAny<Scheduler, Self> {
//        ObserveOnAny(scheduler: scheduler, source: asSubscribeToAny())
//    }
// }
//
// public extension SubscribeToAsyncCallType {
//    func observe<Scheduler: ActorScheduler>(on scheduler: Scheduler) -> ObserveOnAny<Scheduler, Self> {
//        ObserveOnAny(scheduler: scheduler, source: asSubscribeToAny())
//    }
// }
//
// public final class ObserveOnAny<Scheduler: ActorScheduler, Element: Sendable>: SubscribeToSyncCallType {
//    typealias Source = AnySubscribeToCall<Element>
//    public typealias Element = Source.Element
//
//    let scheduler: Scheduler
//    let source: Source
//
//    init(scheduler: Scheduler, source: Source) {
//        self.scheduler = scheduler
//        self.source = source
//    }
//
//    public func subscribe(_ c: C, _ observer: AnySyncObserver<Element>) async -> AnyDisposable {
//        let sink = ObserveOnSink(scheduler: scheduler, observer: observer)
//        let disposable = await source.subscribe(c.call(), sink.asAnyObserver().asAnyObserver())
//        await sink.setInnerSyncDisposable(disposable)
//        return sink.asAnyDisposable().asAnyDisposable()
//    }
// }
//
// public extension SyncObservableToAsyncObserver {
//    func observe(on scheduler: ActorScheduler) -> AsyncObservableToSyncObserver<Element> {
//        ObserveOnSyncToAsync(source: self, scheduler: scheduler)
//    }
// }
//
// final class ObserveOnSyncToAsync<Element: Sendable>: AsyncObservableToSyncObserver<Element> {
//    typealias Source = SyncObservableToAsyncObserver<Element>
//    let source: Source
//    let scheduler: ActorScheduler
//
//    init(source: Source, scheduler: ActorScheduler) {
//        self.source = source
//        self.scheduler = scheduler
//    }
//
//    override func subscribe<Observer>(_ c: C, _ observer: Observer) async -> AnyDisposable
//        where Element == Observer.Element, Observer: SyncObserverType {
//        let sink = ObserveOnSink(scheduler: scheduler, observer: observer)
//        let disp = source.subscribe(c.call(), sink)
//        await sink.setInnerSyncDisposable(.sync(disp))
//        return .async(sink)
//    }
// }
//
// public extension SyncObservableToSyncObserver {
//    func observe(on scheduler: ActorScheduler) -> AsyncObservableToSyncObserver<Element> {
//        ObserveOnSyncToSync(source: self, scheduler: scheduler)
//    }
// }
//
// final class ObserveOnSyncToSync<Element: Sendable>: AsyncObservableToSyncObserver<Element> {
//    typealias Source = SyncObservableToSyncObserver<Element>
//    let source: Source
//    let scheduler: ActorScheduler
//
//    init(source: Source, scheduler: ActorScheduler) {
//        self.source = source
//        self.scheduler = scheduler
//    }
//
//    override func subscribe<Observer>(_ c: C, _ observer: Observer) async -> AnyDisposable
//        where Element == Observer.Element, Observer: SyncObserverType {
//        let sink = ObserveOnSink(scheduler: scheduler, observer: observer)
//        let disp = source.subscribe(c.call(), sink)
//        await sink.setInnerSyncDisposable(.sync(disp))
//        return .async(sink)
//    }
// }

private struct RefIdDisposable: Hashable {
    static func == (
        lhs: RefIdDisposable,
        rhs: RefIdDisposable
    ) -> Bool {
        ObjectIdentifier(lhs.disposable) == ObjectIdentifier(rhs.disposable)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(disposable))
    }

    let disposable: SingleAssignmentSyncDisposable

    init(disposable: SingleAssignmentSyncDisposable) {
        self.disposable = disposable
    }
}

final actor ObserveOnSink<Observer: AsyncObserverType>: AsyncObserverType,
    AsynchronousDisposable, ActorLock {

    public typealias Element = Observer.Element

    let scheduler: AsyncScheduler
    let observer: Observer
    private let sourceSubscription = SingleAssignmentDisposable()

    private var disposeFlags: Set<RefIdDisposable> = Set()

    init(scheduler: AsyncScheduler, observer: Observer) {
        self.scheduler = scheduler
        self.observer = observer
    }

    public func on(_ event: Event<Element>, _ c: C) {
        if sourceSubscription.isDisposed {
            return
        }

        let disp = RefIdDisposable(disposable: SingleAssignmentSyncDisposable())
        disposeFlags.insert(disp)

        let disposeAction = scheduler.perform(c.call()) { [weak self, observer] c in
            await observer.on(event, c.call())
            await self?.handleObserverFinished(disp)
        }

        disp.disposable.setDisposable(disposeAction)?.dispose()
    }

    private func handleObserverFinished(_ disp: RefIdDisposable) {
        disposeFlags.remove(disp)
    }

    func run(_ c: C, _ source: Observable<Element>) async {
        await sourceSubscription.setDisposable(source.subscribe(c.call(), self))?.dispose()
    }

    public func dispose() async {
        let sourceDispose = sourceSubscription.dispose()
        let disposeFlags = disposeFlags
        self.disposeFlags = Set()
        let disposeActions = disposeFlags.map { $0.disposable.dispose() }

        await sourceDispose
        for disposeAction in disposeActions {
            await disposeAction?.dispose()
        }

    }

    func perform<R>(_ work: () -> R) -> R {
        work()
    }
}

////
////  ObserveOn.swift
////  RxSwift
////
////  Created by Krunoslav Zaher on 7/25/15.
////  Copyright © 2015 Krunoslav Zaher. All rights reserved.
////
//
// public extension ObservableType {
//    /**
//     Wraps the source sequence in order to run its observer callbacks on the specified scheduler.
//
//     This only invokes observer callbacks on a `scheduler`. In case the subscription and/or unsubscription
//     actions have side-effects that require to be run on a scheduler, use `subscribeOn`.
//
//     - seealso: [observeOn operator on reactivex.io](http://reactivex.io/documentation/operators/observeon.html)
//
//     - parameter scheduler: Scheduler to notify observers on.
//     - returns: The source sequence whose observations happen on the specified scheduler.
//     */
//    func observe(on scheduler: ImmediateSchedulerType) async
//        -> Observable<Element>
//    {
//        guard let serialScheduler = scheduler as? SerialDispatchQueueScheduler else {
//            return await ObserveOn(source: self.asObservable(), scheduler: scheduler)
//        }
//
//        return await ObserveOnSerialDispatchQueue(source: self.asObservable(),
//                                                  scheduler: serialScheduler)
//    }
//
//    /**
//     Wraps the source sequence in order to run its observer callbacks on the specified scheduler.
//
//     This only invokes observer callbacks on a `scheduler`. In case the subscription and/or unsubscription
//     actions have side-effects that require to be run on a scheduler, use `subscribeOn`.
//
//     - seealso: [observeOn operator on reactivex.io](http://reactivex.io/documentation/operators/observeon.html)
//
//     - parameter scheduler: Scheduler to notify observers on.
//     - returns: The source sequence whose observations happen on the specified scheduler.
//     */
//    @available(*, deprecated, renamed: "observe(on:)")
//    func observeOn(_ scheduler: ImmediateSchedulerType) async
//        -> Observable<Element>
//    {
//        await self.observe(on: scheduler)
//    }
// }
//
//
//
// private final class ObserveOn<Element>: Producer<Element> {
//    let scheduler: ImmediateSchedulerType
//    let source: Observable<Element>
//
//    init(source: Observable<Element>, scheduler: ImmediateSchedulerType) async {
//        self.scheduler = scheduler
//        self.source = source
//
//
//        #if TRACE_RESOURCES
//            _ = await Resources.incrementTotal()
//        #endif
//        await super.init()
//    }
//
//    override func run<Observer: ObserverType>(_ c: C, _ observer: Observer) async ->
//    AsynchronousDisposable where Observer.Element == Element {
//        let sink = await ObserveOnSink(scheduler: self.scheduler, observer: observer)
//        let subscription = await self.source9.subscribe(c.call(), sink)
//        return sink
//    }
//
//    #if TRACE_RESOURCES
//        deinit {
//            Task {
//                _ = await Resources.decrementTotal()
//            }
//        }
//    #endif
// }
//
// enum ObserveOnState: Int32 {
//    // pump is not running
//    case stopped = 0
//    // pump is running
//    case running = 1
// }
//
// private final class ObserveOnSink<Observer: ObserverType>: ObserverBase<Observer.Element> {
//    typealias Element = Observer.Element
//
//    let scheduler: ImmediateSchedulerType
//
//    let lock: SpinLock
//    let observer: Observer
//
//    // state
//    var state = ObserveOnState.stopped
//    var queue = Queue<Event<Element>>(capacity: 10)
//
//    let scheduleDisposable: SerialDisposable
//    let cancel: Cancelable
//
//    init(scheduler: ImmediateSchedulerType, observer: Observer) async {
//        self.scheduleDisposable = await SerialDisposable()
//        self.lock = await SpinLock()
//        self.scheduler = scheduler
//        self.observer = observer
//        self.cancel = cancel
//        await super.init()
//    }
//
//    override func onCore(_ event: Event<Element>, _ c: C) async {
//        let shouldStart = await self.lock.performLocked { () -> Bool in
//            self.queue.enqueue(event)
//
//            switch self.state {
//            case .stopped:
//                self.state = .running
//                return true
//            case .running:
//                return false
//            }
//        }
//
//        if shouldStart {
//            await self.scheduleDisposable.setDisposable(self.scheduler.scheduleRecursive((), c.call(), action:
//            self.run))
//        }
//    }
//
//    func run(_ state: (), _ c: C, _ recurse: (()) async -> Void) async {
//        let (nextEvent, observer) = await self.lock.performLocked { () -> (Event<Element>?, Observer) in
//            if !self.queue.isEmpty {
//                return (self.queue.dequeue(), self.observer)
//            }
//            else {
//                self.state = .stopped
//                return (nil, self.observer)
//            }
//        }
//
//        if let nextEvent = nextEvent, await !self.cancel.isDisposed() {
//            await observer.on(nextEvent, c.call())
//            if nextEvent.isStopEvent {
//                await self.dispose()
//            }
//        }
//        else {
//            return
//        }
//
//        let shouldContinue = await self.shouldContinue_Asynchronous()
//
//        if shouldContinue {
//            await recurse(())
//        }
//    }
//
//    func shouldContinue_Asynchronous() async -> Bool {
//        await self.lock.performLocked {
//            let isEmpty = self.queue.isEmpty
//            if isEmpty { self.state = .stopped }
//            return !isEmpty
//        }
//    }
//
//    override func dispose() async {
//        await super.dispose()
//
//        await self.cancel.dispose()
//        await self.scheduleDisposable.dispose()
//    }
// }
//
// #if TRACE_RESOURCES
//    var numberOfSerialDispatchObservables: ActualAtomicInt!
//
//    public extension Resources {
//        /**
//         Counts number of `SerialDispatchQueueObservables`.
//
//         Purposed for unit tests.
//         */
//        static func numberOfSerialDispatchQueueObservables() async -> Int32 {
//            await load(numberOfSerialDispatchObservables)
//        }
//    }
// #endif
//
// private final class ObserveOnSerialDispatchQueueSink<Observer: ObserverType>: ObserverBase<Observer.Element> {
//    let scheduler: SerialDispatchQueueScheduler
//    let observer: Observer
//
//    let cancel: Cancelable
//
//    var cachedScheduleLambda: ((C, (sink: ObserveOnSerialDispatchQueueSink<Observer>, event: Event<Element>)) async ->
//    Disposable)!
//
//    init(scheduler: SerialDispatchQueueScheduler, observer: Observer) async {
//        self.scheduler = scheduler
//        self.observer = observer
//        self.cancel = cancel
//        await super.init()
//
//        self.cachedScheduleLambda = { c, pair in
//            guard await !cancel.isDisposed() else { return Disposables.create() }
//
//            await pair.sink.observer.on(pair.event, c.call())
//
//            if pair.event.isStopEvent {
//                await pair.sink.dispose()
//            }
//
//            return Disposables.create()
//        }
//    }
//
//    override func onCore(_ event: Event<Element>, _ c: C) async {
//        _ = await self.scheduler.schedule((self, event), c.call(), action: self.cachedScheduleLambda!)
//    }
//
//    override func dispose() async {
//        await super.dispose()
//
//        await self.cancel.dispose()
//    }
// }
//
// private final class ObserveOnSerialDispatchQueue<Element>: Producer<Element> {
//    let scheduler: SerialDispatchQueueScheduler
//    let source: Observable<Element>
//
//    init(source: Observable<Element>, scheduler: SerialDispatchQueueScheduler) async {
//        self.scheduler = scheduler
//        self.source = source
//
//        #if TRACE_RESOURCES
//            _ = await Resources.incrementTotal()
//            _ = await increment(numberOfSerialDispatchObservables)
//        #endif
//        await super.init()
//    }
//
//    override func run<Observer: ObserverType>(_ c: C, _ observer: Observer) async -> AsynchronousDisposable where
//    Observer.Element == Element {
//        let sink = await ObserveOnSerialDispatchQueueSink(scheduler: self.scheduler, observer: observer)
//        let subscription = await self.source.subscribe(c.call(), sink)
//        return sink
//    }
//
//    #if TRACE_RESOURCES
//        deinit {
//            Task {
//                _ = await Resources.decrementTotal()
//                _ = await decrement(numberOfSerialDispatchObservables)
//            }
//        }
//    #endif
// }
