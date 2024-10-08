//
//  Observable+FilterTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

#if os(Linux)
    import Glibc
#endif

class ObservableFilterTest : RxTest {
}

func isPrime(_ i: Int) -> Bool {
    if i <= 1 {
        return false
    }
    
    let max = Int(sqrt(Double(i)))
    if max <= 1 {
        return true
    }

    for j in 2 ... max where i % j == 0 {
        return false
    }
    
    return true
}

extension ObservableFilterTest {
    func test_filterComplete() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = await scheduler.createHotObservable([
            .next(110, 1),
            .next(180, 2),
            .next(230, 3),
            .next(270, 4),
            .next(340, 5),
            .next(380, 6),
            .next(390, 7),
            .next(450, 8),
            .next(470, 9),
            .next(560, 10),
            .next(580, 11),
            .completed(600),
            .next(610, 12),
            .error(620, testError),
            .completed(630)
        ])
        
        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.filter { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(230, 3),
            .next(340, 5),
            .next(390, 7),
            .next(580, 11),
            .completed(600)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
        ])
        
        XCTAssertEqual(9, invoked)
    }
    
    func test_filterTrue() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = await scheduler.createHotObservable([
            .next(110, 1),
            .next(180, 2),
            .next(230, 3),
            .next(270, 4),
            .next(340, 5),
            .next(380, 6),
            .next(390, 7),
            .next(450, 8),
            .next(470, 9),
            .next(560, 10),
            .next(580, 11),
            .completed(600)
            ])
        
        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.filter { _ -> Bool in
                invoked += 1
                return true
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(230, 3),
            .next(270, 4),
            .next(340, 5),
            .next(380, 6),
            .next(390, 7),
            .next(450, 8),
            .next(470, 9),
            .next(560, 10),
            .next(580, 11),
            .completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
        
        XCTAssertEqual(9, invoked)
    }
   
    func test_filterFalse() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = await scheduler.createHotObservable([
            .next(110, 1),
            .next(180, 2),
            .next(230, 3),
            .next(270, 4),
            .next(340, 5),
            .next(380, 6),
            .next(390, 7),
            .next(450, 8),
            .next(470, 9),
            .next(560, 10),
            .next(580, 11),
            .completed(600)
            ])
        
        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.filter { _ -> Bool in
                invoked += 1
                return false
            }
        }
        
        XCTAssertEqual(res.events, [
            .completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
        
        XCTAssertEqual(9, invoked)
    }
    
    func test_filterDisposed() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = await scheduler.createHotObservable([
            .next(110, 1),
            .next(180, 2),
            .next(230, 3),
            .next(270, 4),
            .next(340, 5),
            .next(380, 6),
            .next(390, 7),
            .next(450, 8),
            .next(470, 9),
            .next(560, 10),
            .next(580, 11),
            .completed(600)
            ])
        
        let res = await scheduler.start(disposed: 400) { () -> Observable<Int> in
            return await xs.filter { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(230, 3),
            .next(340, 5),
            .next(390, 7)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(5, invoked)
    }

    #if TRACE_RESOURCES
    func testFilterReleasesResourcesOnComplete() async {
        _ = await Observable<Int>.just(1).filter { _ in true }.subscribe()
        }

    func testFilter1ReleasesResourcesOnError() async {
        _ = await Observable<Int>.error(testError).filter { _ in true }.subscribe()
        }

    func testFilter2ReleasesResourcesOnError() async {
        _ = await Observable<Int>.just(1).filter { _ -> Bool in throw testError }.subscribe()
        }
    #endif
}

extension ObservableFilterTest {
    func testIgnoreElements_DoesNotSendValues() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(210, 1),
            .next(220, 2),
            .completed(230)
            ])

        let res = await scheduler.start {
            await xs.ignoreElements()
        }

        XCTAssertEqual(res.events, [
            .completed(230)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    #if TRACE_RESOURCES
    func testIgnoreElementsReleasesResourcesOnComplete() async {
        _ = await Observable<Int>.just(1).ignoreElements().subscribe()
        }

    func testIgnoreElementsReleasesResourcesOnError() async {
        _ = await Observable<Int>.error(testError).ignoreElements().subscribe()
        }
    #endif
}
