//
//  AtomicInt.swift
//  Platform
//
//  Created by Krunoslav Zaher on 10/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import Foundation

public final class TheActualAtomicInt<Value: FixedWidthInteger>: @unchecked Sendable {
    fileprivate let lock: ActualNonRecursiveLock
    fileprivate var value: Value

    public init(_ value: Value = 0) {
        lock = ActualNonRecursiveLock()
        self.value = value
    }

    func perform<R: Sendable>(_ c: C, _ work: @Sendable @escaping (C, inout Value) -> R) async -> R {
        await lock.performLocked(c) { c in
            work(c, &self.value)
        }
    }
}

public typealias ActualAtomicInt = TheActualAtomicInt<Int32>

@discardableResult
@inline(__always)
func add(_ this: ActualAtomicInt, _ value: Int32) async -> Int32 {
    await this.lock.performLocked {
        let oldValue = this.value
        this.value += value
        return oldValue
    }
}

@discardableResult
@inline(__always)
func sub(_ this: ActualAtomicInt, _ value: Int32) async -> Int32 {
    await this.lock.performLocked {
        let oldValue = this.value
        this.value -= value
        return oldValue
    }
}

@discardableResult
@inline(__always)
func fetchOr(_ this: ActualAtomicInt, _ mask: Int32) async -> Int32 {
    await this.lock.performLocked {
        let oldValue = this.value
        this.value |= mask
        return oldValue
    }
}

@inline(__always)
func load(_ this: ActualAtomicInt) async -> Int32 {
    await this.lock.performLocked {
        let oldValue = this.value
        return oldValue
    }
}

@discardableResult
@inline(__always)
func increment(_ this: ActualAtomicInt) async -> Int32 {
    await add(this, 1)
}

@discardableResult
@inline(__always)
func decrement(_ this: ActualAtomicInt) async -> Int32 {
    await sub(this, 1)
}

@inline(__always)
func isFlagSet(_ this: ActualAtomicInt, _ mask: Int32) async -> Bool {
    await (load(this) & mask) != 0
}

final class NonAtomicInt: @unchecked Sendable {
    fileprivate var value: Int32

    public init(_ value: Int32 = 0) {
        self.value = value
    }
}

@discardableResult
@inline(__always)
func add(_ this: NonAtomicInt, _ value: Int32) -> Int32 {
    let oldValue = this.value
    this.value += value
    return oldValue
}

@discardableResult
@inline(__always)
func sub(_ this: NonAtomicInt, _ value: Int32) -> Int32 {
    let oldValue = this.value
    this.value -= value
    return oldValue
}

@discardableResult
@inline(__always)
func fetchOr(_ this: NonAtomicInt, _ mask: Int32) -> Int32 {
    let oldValue = this.value
    this.value |= mask
    return oldValue
}

@inline(__always)
func load(_ this: NonAtomicInt) -> Int32 {
    let oldValue = this.value
    return oldValue
}

@discardableResult
@inline(__always)
func increment(_ this: NonAtomicInt) -> Int32 {
    add(this, 1)
}

@discardableResult
@inline(__always)
func decrement(_ this: NonAtomicInt) -> Int32 {
    sub(this, 1)
}

@inline(__always)
func isFlagSet(_ this: NonAtomicInt, _ mask: Int32) -> Bool {
    (load(this) & mask) != 0
}
