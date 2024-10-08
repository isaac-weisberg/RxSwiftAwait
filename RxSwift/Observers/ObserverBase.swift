//
//  ObserverBase.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

//class ObserverBase<Element>: Disposable, ObserverType {
//    private let isStopped: AtomicInt
//    
//    init() async {
//        self.isStopped = await AtomicInt(0)
//    }
//
//    func on(_ event: Event<Element>, _ c: C) async {
//        switch event {
//        case .next:
//            if await load(self.isStopped) == 0 {
//                await self.onCore(event, c.call())
//            }
//        case .error, .completed:
//            if await fetchOr(self.isStopped, 1) == 0 {
//                await self.onCore(event, c.call())
//            }
//        }
//    }
//
//    func onCore(_ event: Event<Element>, _ c: C) async {
//        rxAbstractMethod()
//    }
//
//    func dispose() async {
//        await fetchOr(self.isStopped, 1)
//    }
//}
