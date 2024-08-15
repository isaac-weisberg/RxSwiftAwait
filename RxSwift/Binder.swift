////
////  Binder.swift
////  RxSwift
////
////  Created by Krunoslav Zaher on 9/17/17.
////  Copyright © 2017 Krunoslav Zaher. All rights reserved.
////
//
///**
// Observer that enforces interface binding rules:
// * can't bind errors (in debug builds binding of errors causes `fatalError` in release builds errors are being logged)
// * ensures binding is performed on a specific scheduler
//
// `Binder` doesn't retain target and in case target is released, element isn't bound.
//
// By default it binds elements on main scheduler.
// */
//public struct Binder<Value>: ObserverType {
//    public typealias Element = Value
//
//    private let binding: (C, Event<Value>) async -> Void
//
//    /// Initializes `Binder`
//    ///
//    /// - parameter target: Target object.
//    /// - parameter scheduler: Scheduler used to bind the events.
//    /// - parameter binding: Binding logic.
//    public init<Target: AnyObject>(_ target: Target, scheduler schedulerOpt: ImmediateSchedulerType? = nil, binding: @escaping (Target, Value) async -> Void) async {
//        let scheduler: ImmediateSchedulerType
//        if let schedulerOpt {
//            scheduler = schedulerOpt
//        } else {
//            scheduler = await MainScheduler()
//        }
//        weak var weakTarget = target
//
//        self.binding = { c, event in
//            switch event {
//            case .next(let element):
//                _ = await scheduler.schedule(element, c.call()) { c, element in
//                    if let target = weakTarget {
//                        await binding(target, element)
//                    }
//                    return Disposables.create()
//                }
//            case .error(let error):
//                rxFatalErrorInDebug("Binding error: \(error)")
//            case .completed:
//                break
//            }
//        }
//    }
//
//    /// Binds next element to owner view as described in `binding`.
//    public func on(_ event: Event<Value>, _ c: C) async {
//        await self.binding(c.call(), event)
//    }
//
//    /// Erases type of observer.
//    ///
//    /// - returns: type erased observer.
//    public func asObserver() -> AnyObserver<Value> {
//        AnyObserver(eventHandler: { c, e in
//            await self.on(e, c)
//        })
//    }
//}
