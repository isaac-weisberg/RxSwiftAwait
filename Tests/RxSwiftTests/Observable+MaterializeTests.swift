//
//  Observable+MaterializeTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableMaterializeTest : RxTest {
}

extension ObservableMaterializeTest {
    func testMaterializeNever() async {
        let scheduler = await TestScheduler(initialClock: 0)
        let res = await scheduler.start {
            return await Observable<Int>.never().materialize()
        }
        XCTAssertEqual(res.events, [], materializedRecoredEventsComparison)
    }
    
    func testMaterializeEmpty() async {
        let scheduler = await TestScheduler(initialClock: 0)
        let xs = await scheduler.createHotObservable([
            .completed(201, Int.self),
            .completed(202, Int.self),
            ])
        let res = await scheduler.start {
            return await xs.materialize()
        }
        let expectedEvents = Recorded.events(
            .next(201, Event<Int>.completed),
            .completed(201)
        )
        
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 201)])
        XCTAssertEqual(res.events, expectedEvents, materializedRecoredEventsComparison)
    }
    
    func testMaterializeEmits() async {
        let scheduler = await TestScheduler(initialClock: 0)
        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .completed(250),
            .completed(251),
            ])
        let res = await scheduler.start {
            return await xs.materialize()
        }
        let expectedEvents = Recorded.events(
            .next(210, Event.next(2)),
            .next(250, Event.completed),
            .completed(250)
        )
        
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 250)])
        XCTAssertEqual(res.events, expectedEvents, materializedRecoredEventsComparison)
    }
    
    func testMaterializeThrow() async {
        let scheduler = await TestScheduler(initialClock: 0)
        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .error(250, testError),
            .error(251, testError),
            ])
        let res = await scheduler.start {
            return await xs.materialize()
        }
        let expectedEvents = Recorded.events(
            .next(250, Event<Int>.error(testError)),
            .completed(250)
        )
        
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 250)])
        XCTAssertEqual(res.events, expectedEvents, materializedRecoredEventsComparison)
    }
    
    #if TRACE_RESOURCES
    func testMaterializeReleasesResourcesOnComplete1() async {
        _ = await Observable<Int>.just(1).materialize().subscribe()
        }
        
    func testMaterializeReleasesResourcesOnComplete2() async {
        _ = await Observable<Int>.empty().materialize().subscribe()
        }
        
    func testMaterializeReleasesResourcesOnError() async {
        _ = await Observable<Int>.error(testError).materialize().subscribe()
        }
    #endif
}

private func materializedRecoredEventsComparison<T: Equatable>(lhs: [Recorded<Event<Event<T>>>], rhs: [Recorded<Event<Event<T>>>]) -> Bool {
    guard lhs.count == rhs.count else {
        return false
    }
    for (lhsElement, rhsElement) in zip(lhs, rhs) {
        guard lhsElement == rhsElement else {
            return false
        }
    }
    
    return true
}

private func == <T: Equatable>(lhs: Recorded<Event<Event<T>>>, rhs: Recorded<Event<Event<T>>>) -> Bool {
    return lhs.time == rhs.time && lhs.value == rhs.value
}

private func == <T: Equatable>(lhs: Event<Event<T>>, rhs: Event<Event<T>>) -> Bool {
    switch (lhs, rhs) {
    case let (.next(lhsEvent), .next(rhsEvent)):
        return lhsEvent == rhsEvent
    case (.completed, .completed): return true
    case let (.error(e1), .error(e2)):
        #if os(Linux)
            return  "\(e1)" == "\(e2)"
        #else
            let error1 = e1 as NSError
            let error2 = e2 as NSError
            
            return error1.domain == error2.domain
                && error1.code == error2.code
                && "\(e1)" == "\(e2)"
        #endif
    default:
        return false
    }
}
