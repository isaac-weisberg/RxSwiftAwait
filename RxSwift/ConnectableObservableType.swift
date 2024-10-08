//
//  ConnectableObservableType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/**
 Represents an observable sequence wrapper that can be connected and disconnected from its underlying observable sequence.
 */
public protocol ConnectableObservableType: ObservableType {
    /**
     Connects the observable wrapper to its source. All subscribed observers will receive values from the underlying observable sequence as long as the connection is established.

     - returns: Disposable used to disconnect the observable wrapper from its source, causing subscribed observer to stop receiving values from the underlying observable sequence.
     */
    func connect(_ c: C) async -> Disposable
}

public extension ConnectableObservableType {

    #if VICIOUS_TRACING
        func connect(
            file: StaticString = #file,
            function: StaticString = #function,
            line: UInt = #line
        )
            async -> Disposable {
            await connect(C(file, function, line))
        }
    #else
        func connect() async -> Disposable {
            await connect(C())
        }
    #endif
}
