//
//  Observable+ScanTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableScanTest : RxTest {
}

extension ObservableScanTest {
    func testScan_Seed_Never() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(0, 0)
            ])

        let seed = 42

        let res = await scheduler.start {
            await xs.scan(seed) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }

    func testScan_Into_Never() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(0, 0)
            ])

        let seed = 42

        let res = await scheduler.start {
            await xs.scan(into: seed) { $0 += $1 }
        }

        XCTAssertEqual(res.events, [
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }

    func testScan_Seed_Empty() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(250)
            ])

        let seed = 42

        let res = await scheduler.start {
            await xs.scan(seed) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [
            .completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testScan_Into_Empty() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(250)
            ])

        let seed = 42

        let res = await scheduler.start {
            await xs.scan(into: seed) { $0 += $1 }
        }

        XCTAssertEqual(res.events, [
            .completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testScan_Seed_Return() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .completed(250)
            ])

        let seed = 42

        let res = await scheduler.start {
            await xs.scan(seed) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [
            .next(220, seed + 2),
            .completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testScan_Into_Accumulate() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .completed(250)
            ])

        let seed = 42

        let res = await scheduler.start {
            await xs.scan(into: seed) { $0 += $1 }
        }

        XCTAssertEqual(res.events, [
            .next(220, seed + 2),
            .completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testScan_Seed_Throw() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .error(250, testError)
            ])

        let seed = 42

        let res = await scheduler.start {
            await xs.scan(seed) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [
            .error(250, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testScan_Into_Throw() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .error(250, testError)
            ])

        let seed = 42

        let res = await scheduler.start {
            await xs.scan(into: seed) { $0 += $1 }
        }

        XCTAssertEqual(res.events, [
            .error(250, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testScan_Seed_SomeData() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
            ])

        let seed = 42

        let res = await scheduler.start {
            await xs.scan(seed) { $0 + $1 }
        }

        let messages = Recorded.events(
            .next(210, seed + 2),
            .next(220, seed + 2 + 3),
            .next(230, seed + 2 + 3 + 4),
            .next(240, seed + 2 + 3 + 4 + 5),
            .completed(250)
        )

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testScan_Into_SomeData() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
            ])

        let seed = 42

        let res = await scheduler.start {
            await xs.scan(into: seed) { $0 += $1 }
        }

        let messages = Recorded.events(
            .next(210, seed + 2),
            .next(220, seed + 2 + 3),
            .next(230, seed + 2 + 3 + 4),
            .next(240, seed + 2 + 3 + 4 + 5),
            .completed(250)
        )

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testScan_Seed_AccumulatorThrows() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
            ])

        let seed = 42

        let res = await scheduler.start {
            await xs.scan(seed) { (a, e) throws -> Int in
                if e == 4 {
                    throw testError
                } else {
                    return a + e
                }
            }
        }

        XCTAssertEqual(res.events, [
            .next(210, seed + 2),
            .next(220, seed + 2 + 3),
            .error(230, testError)
            ] as [Recorded<Event<Int>>])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    func testScan_Into_AccumulatorThrows() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
            ])

        let seed = 42

        let res = await scheduler.start {
            await xs.scan(into: seed) { a, e in
                if e == 4 {
                    throw testError
                } else {
                    a += e
                }
            }
        }

        XCTAssertEqual(res.events, [
            .next(210, seed + 2),
            .next(220, seed + 2 + 3),
            .error(230, testError)
            ] as [Recorded<Event<Int>>])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }


    #if TRACE_RESOURCES
    func testScanReleasesResourcesOnComplete() async {
        _ = await Observable<Int>.just(1).scan(0, accumulator: +).subscribe()
        }

    func testScan1ReleasesResourcesOnError() async {
        _ = await Observable<Int>.error(testError).scan(0, accumulator: +).subscribe()
        }

    func testScan2ReleasesResourcesOnError() async {
        _ = await Observable<Int>.just(1).scan(0, accumulator: { _, _ in throw testError }).subscribe()
        }
    #endif
}

