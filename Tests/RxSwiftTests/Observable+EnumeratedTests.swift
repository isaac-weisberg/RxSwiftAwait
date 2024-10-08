//
//  Observable+EnumeratedTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 8/6/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableEnumeratedTest : RxTest {
}

extension ObservableEnumeratedTest {

    func test_Infinite() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(210, "a"),
            .next(220, "b"),
            .next(280, "c")
            ])

        let res = await scheduler.start {
            await xs.enumerated()
        }

        XCTAssertArraysEqual(res.events, [
            .next(210, (index: 0, element: "a")),
            .next(220, (index: 1, element: "b")),
            .next(280, (index: 2, element: "c"))
        ] as [Recorded<Event<(index: Int, element: String)>>], compareRecordedEvents)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }

    func test_Completed() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(210, "a"),
            .next(220, "b"),
            .next(280, "c"),
            .completed(300)
            ])

        let res = await scheduler.start {
            await xs.enumerated()
        }

        XCTAssertArraysEqual(res.events, [
            .next(210, (index: 0, element: "a")),
            .next(220, (index: 1, element: "b")),
            .next(280, (index: 2, element: "c")),
            .completed(300)
        ] as [Recorded<Event<(index: Int, element: String)>>], compareRecordedEvents)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
    }

    func test_Error() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(210, "a"),
            .next(220, "b"),
            .next(280, "c"),
            .error(300, testError)
            ])

        let res = await scheduler.start {
            await xs.enumerated()
        }

        XCTAssertArraysEqual(res.events, [
            .next(210, (index: 0, element: "a")),
            .next(220, (index: 1, element: "b")),
            .next(280, (index: 2, element: "c")),
            .error(300, testError)
            ] as [Recorded<Event<(index: Int, element: String)>>], compareRecordedEvents)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
    }

    #if TRACE_RESOURCES
    func testEnumeratedReleasesResourcesOnComplete() async {
        _ = await Observable<Int>.just(1).enumerated().subscribe()
        }

    func testEnumeratedReleasesResourcesOnError() async {
        _ = await Observable<Int>.error(testError).enumerated().subscribe()
        }
    #endif
}

private func compareRecordedEvents(lhs: Recorded<Event<(index: Int, element: String)>>, rhs: Recorded<Event<(index: Int, element: String)>>) -> Bool {
    return lhs.time == rhs.time && { (lhs: Event<(index: Int, element: String)>, rhs: Event<(index: Int, element: String)>) in
        switch (lhs, rhs) {
        case let (.next(lhs), .next(rhs)):
            return lhs == rhs
        case (.next, _):
            return false
        case let (.error(lhs), .error(rhs)):
            return Event<Int>.error(lhs) == Event<Int>.error(rhs)
        case (.error, _):
            return false
        case (.completed, .completed):
            return true
        case (.completed, _):
            return false
        }
    }(lhs.value, rhs.value)
}
