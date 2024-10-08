//
//  Observable+UsingTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableUsingTest : RxTest {
}

extension ObservableUsingTest {
    func testUsing_Complete() async {
        let scheduler = await TestScheduler(initialClock: 0)

        var disposeInvoked = 0
        var createInvoked = 0

        var xs: TestableObservable<Int>!
        var disposable: MockDisposable!
        var _d: MockDisposable!

        let res = await scheduler.start {
            await Observable.using({ () -> MockDisposable in
                disposeInvoked += 1
                disposable = MockDisposable(scheduler: scheduler)
                return disposable
            }, observableFactory: { d in
                _d = d
                createInvoked += 1
                xs = await scheduler.createColdObservable([
                    .next(100, scheduler.clock),
                    .completed(200)
                    ])
                return await xs.asObservable()
            }) as Observable<Int>
        }

        XCTAssert(disposable === _d)

        XCTAssertEqual(res.events, [
            .next(300, 200),
            .completed(400)
            ])

        XCTAssertEqual(1, createInvoked)
        XCTAssertEqual(1, disposeInvoked)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])

        XCTAssertEqual(disposable.ticks, [
            200,
            400
            ])
    }

    func testUsing_Error() async {
        let scheduler = await TestScheduler(initialClock: 0)

        var disposeInvoked = 0
        var createInvoked = 0

        var xs: TestableObservable<Int>!
        var disposable: MockDisposable!
        var _d: MockDisposable!

        let res = await scheduler.start {
            await Observable.using({ () -> MockDisposable in
                disposeInvoked += 1
                disposable = MockDisposable(scheduler: scheduler)
                return disposable
            }, observableFactory: { d in
                _d = d
                createInvoked += 1
                xs = await scheduler.createColdObservable([
                    .next(100, scheduler.clock),
                    .error(200, testError)
                    ])
                return await xs.asObservable()
            }) as Observable<Int>
        }

        XCTAssert(disposable === _d)

        XCTAssertEqual(res.events, [
            .next(300, 200),
            .error(400, testError)
            ])

        XCTAssertEqual(1, createInvoked)
        XCTAssertEqual(1, disposeInvoked)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])

        XCTAssertEqual(disposable.ticks, [
            200,
            400
            ])
    }

    func testUsing_Dispose() async {
        let scheduler = await TestScheduler(initialClock: 0)

        var disposeInvoked = 0
        var createInvoked = 0

        var xs: TestableObservable<Int>!
        var disposable: MockDisposable!
        var _d: MockDisposable!

        let res = await scheduler.start {
            await Observable.using({ () -> MockDisposable in
                disposeInvoked += 1
                disposable = MockDisposable(scheduler: scheduler)
                return disposable
            }, observableFactory: { d in
                _d = d
                createInvoked += 1
                xs = await scheduler.createColdObservable([
                    .next(100, scheduler.clock),
                    .next(1000, scheduler.clock + 1)
                    ])
                return await xs.asObservable()
            }) as Observable<Int>
        }

        XCTAssert(disposable === _d)

        XCTAssertEqual(res.events, [
            .next(300, 200),
            ])

        XCTAssertEqual(1, createInvoked)
        XCTAssertEqual(1, disposeInvoked)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])

        XCTAssertEqual(disposable.ticks, [
            200,
            1000
            ])
    }

    func testUsing_ThrowResourceSelector() async {
        let scheduler = await TestScheduler(initialClock: 0)

        var disposeInvoked = 0
        var createInvoked = 0

        let res = await scheduler.start {
            await Observable.using({ () -> MockDisposable in
                disposeInvoked += 1
                throw testError
            }, observableFactory: { _ in
                createInvoked += 1
                return await Observable.never()

            }) as Observable<Int>
        }

        XCTAssertEqual(res.events, [
            .error(200, testError),
            ])

        XCTAssertEqual(0, createInvoked)
        XCTAssertEqual(1, disposeInvoked)
    }

    func testUsing_ThrowResourceUsage() async {
        let scheduler = await TestScheduler(initialClock: 0)

        var disposeInvoked = 0
        var createInvoked = 0
        var disposable: MockDisposable!

        let res = await scheduler.start {
            await Observable.using({ () -> MockDisposable in
                disposeInvoked += 1
                disposable = MockDisposable(scheduler: scheduler)
                return disposable
            }, observableFactory: { _ in
                createInvoked += 1
                throw testError

            }) as Observable<Int>
        }

        XCTAssertEqual(res.events, [
            .error(200, testError),
            ])

        XCTAssertEqual(1, createInvoked)
        XCTAssertEqual(1, disposeInvoked)

        XCTAssertEqual(disposable.ticks, [
            200,
            200
            ])
    }

    #if TRACE_RESOURCES
    func testUsingReleasesResourcesOnComplete() async {
        let compositeDisposable = await CompositeDisposable(disposables: [])
        _ = await Observable<Int>.using({ compositeDisposable } , observableFactory: { _ in await Observable<Int>.just(1) }).subscribe()
        }

    func testUsingReleasesResourcesOnError() async {
        let compositeDisposable = await CompositeDisposable(disposables: [])
        _ = await Observable<Int>.using({ compositeDisposable } , observableFactory: { _ in await Observable<Int>.error(testError) }).subscribe()
        }
    #endif
}
