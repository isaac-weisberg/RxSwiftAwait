//
//  Observable+RetryWhenTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

import Foundation

class ObservableRetryWhenTest : RxTest {
}

struct CustomErrorType : Error {

}

struct RetryWhenError: Error {
    init() {

    }
}

let retryError: RetryWhenError = RetryWhenError()

// retryWhen
extension ObservableRetryWhenTest {

    func testRetryWhen_Never() async {

        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(250)
            ])

        let empty = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(210)
            ])

        let res = await scheduler.start(disposed: 300) {
            await xs.retry { _ in
                return empty
            }
        }

        let correct = [
            Recorded.completed(250, Int.self)
        ]

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testRetryWhen_ObservableNever() async {

        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .error(250, retryError)
            ])

        let never = await scheduler.createHotObservable([
            .next(150, 1)
            ])

        let res = await scheduler.start {
            await xs.retry { _ in
                return never
            }
        }

        let correct = Recorded.events(
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testRetryWhen_ObservableNeverComplete() async {

        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
            ])

        let never = await scheduler.createHotObservable([
            .next(150, 1)
            ])

        let res = await scheduler.start {
            await xs.retry { _ in
                return never
            }
        }

        let correct = Recorded.events(
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testRetryWhen_ObservableEmpty() async {

        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createColdObservable([
            .next(100, 1),
            .next(150, 2),
            .next(200, 3),
            .completed(250)
            ])

        let empty = await scheduler.createHotObservable([
            .next(150, 0),
            .completed(0)
            ])

        let res = await scheduler.start {
            await xs.retry { _ in
                return empty
            }
        }

        let correct = Recorded.events(
            .next(300, 1),
            .next(350, 2),
            .next(400, 3),
            .completed(450)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450)
            ])
    }


    func testRetryWhen_ObservableNextError() async {

        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createColdObservable([
            .next(10, 1),
            .next(20, 2),
            .error(30, retryError),
            .completed(40)
            ])

        let res = await scheduler.start(disposed: 300) {
            await xs.retry { (errors: Observable<RetryWhenError>) in
                return await errors.scan(0) { _a, _ in
                    var a = _a
                    a += 1
                    if a == 2 {
                        throw testError1
                    }
                    return a
                }
            }
        }

        let correct = Recorded.events(
            .next(210, 1),
            .next(220, 2),
            .next(240, 1),
            .next(250, 2),
            .error(260, testError1)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230),
            Subscription(230, 260)
            ])
    }


    func testRetryWhen_ObservableComplete() async {

        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createColdObservable([
            .next(10, 1),
            .next(20, 2),
            .error(30, retryError),
            .completed(40)
            ])

        let empty = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(230)
            ])

        let res = await scheduler.start {
            await xs.retry { _ in
                return await empty.asObservable()
            }
        }

        let correct = Recorded.events(
            .next(210, 1),
            .next(220, 2),
            .completed(230)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    func testRetryWhen_ObservableNextComplete() async {

        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createColdObservable([
            .next(10, 1),
            .next(20, 2),
            .error(30, retryError),
            .completed(40)
            ])

        let res = await scheduler.start(disposed: 300) {
            await xs.retry { (errors: Observable<RetryWhenError>) in
                return await errors.scan(0) { a, _ in
                    return a + 1
                }.take(while: { (num: Int) -> Bool in
                    return num < 2
                })
            }
        }

        let correct = Recorded.events(
            .next(210, 1),
            .next(220, 2),
            .next(240, 1),
            .next(250, 2),
            .completed(260)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230),
            Subscription(230, 260)
            ])
    }

    func testRetryWhen_ObservableInfinite() async {

        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createColdObservable([
            .next(10, 1),
            .next(20, 2),
            .error(30, retryError),
            .completed(40)
            ])

        let never = await scheduler.createHotObservable([
            .next(150, 1)
            ])

        let res = await scheduler.start {
            await xs.retry { _ in
                return never
            }
        }

        let correct = Recorded.events(
            .next(210, 1),
            .next(220, 2)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }


    func testRetryWhen_Incremental_BackOff() async {

        let scheduler = await TestScheduler(initialClock: 0)

        // just fails
        let xs = await scheduler.createColdObservable([
            .next(5, 1),
            .error(10, retryError)
            ])

        let maxAttempts = 4

        let res = await scheduler.start(disposed: 800) {
            await xs.retry { (errors: Observable<Swift.Error>) in
                return await errors.enumerated().flatMap { a, e -> Observable<Int64> in
                    if a >= maxAttempts - 1 {
                        return await Observable.error(e)
                    }

                    return await Observable<Int64>.timer(.seconds((a + 1) * 50), scheduler: scheduler)
                }
            }
        }

        let correct = Recorded.events(
            .next(205, 1),
            .next(265, 1),
            .next(375, 1),
            .next(535, 1),
            .error(540, retryError)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210),
            Subscription(260, 270),
            Subscription(370, 380),
            Subscription(530, 540)
            ])
    }

    func testRetryWhen_IgnoresDifferentErrorTypes() async {

        let scheduler = await TestScheduler(initialClock: 0)

        // just fails
        let xs = await scheduler.createColdObservable([
            .next(5, 1),
            .error(10, retryError)
            ])

        let res = await scheduler.start(disposed: 800) {
            await xs.retry { (errors: Observable<CustomErrorType>) in
                errors
            }
        }

        let correct = Recorded.events(
            .next(205, 1),
            .error(210, retryError)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    func testRetryWhen_tailRecursiveOptimizationsTest() async {
        var count = 1
        let sequenceSendingImmediateError: Observable<Int> = await Observable.create { observer in
            await observer.on(.next(0))
            await observer.on(.next(1))
            await observer.on(.next(2))
            if count < 2 {
                await observer.on(.error(retryError))
                count += 1
            }
            await observer.on(.next(3))
            await observer.on(.next(4))
            await observer.on(.next(5))
            await observer.on(.completed)

            return Disposables.create()
        }

        _ = await sequenceSendingImmediateError
            .retry { errors in
                return errors
            }
            .subscribe { _ in
        }
    }

    #if TRACE_RESOURCES
    func testRetryWhen1ReleasesResourcesOnComplete() async {
        _ = await Observable<Int>.just(1).retry { e in e }.subscribe()
        }

    func testRetryWhen2ReleasesResourcesOnComplete() async {
        _ = await Observable<Int>.error(testError).retry { e in await e.take(1) }.subscribe()
        }

    func testRetryWhen1ReleasesResourcesOnError() async {
        _ = await Observable<Int>.error(testError).retry { e in
            return await e.flatMapLatest { e in
                return await Observable<Int>.error(e)
                }
            }.subscribe()
        }
    #endif
}
