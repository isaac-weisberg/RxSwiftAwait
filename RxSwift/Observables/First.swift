////
////  First.swift
////  RxSwift
////
////  Created by Krunoslav Zaher on 7/31/17.
////  Copyright © 2017 Krunoslav Zaher. All rights reserved.
////
//
//private final actor FirstSink<Element, Observer: ObserverType>: Sink, ObserverType where Observer.Element == Element? {
//    typealias Parent = First<Element>
//    let baseSink: BaseSink<Observer>
//    
//    init(observer: Observer) async {
//        self.baseSink = BaseSink(observer: observer)
//    }
//
//    func on(_ event: Event<Element>, _ c: C) async {
//        switch event {
//        case .next(let value):
//            await self.forwardOn(.next(value), c.call())
//            await self.forwardOn(.completed, c.call())
//            await self.dispose()
//        case .error(let error):
//            await self.forwardOn(.error(error), c.call())
//            await self.dispose()
//        case .completed:
//            await self.forwardOn(.next(nil), c.call())
//            await self.forwardOn(.completed, c.call())
//            await self.dispose()
//        }
//    }
//}
//
//final class First<Element>: Producer<Element?> {
//    private let source: Observable<Element>
//
//    init(source: Observable<Element>) async {
//        self.source = source
//        await super.init()
//    }
//
//    override func run<Observer: ObserverType>(_ c: C, _ observer: Observer) async -> AsynchronousDisposable where Observer.Element == Element? {
//        let sink = await FirstSink(observer: observer)
//        let subscription = await self.source.subscribe(c.call(), sink)
//        return sink
//    }
//}
