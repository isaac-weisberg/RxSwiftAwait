//
//  Observable+SingleTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableSingleTest : RxTest {
}

extension ObservableSingleTest {
    
    func testSingle_Empty() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(250)
            ])
        
        let res = await scheduler.start {
            await xs.single()
        }
        
        XCTAssertEqual(res.events, [
            .error(250, RxError.noElements)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testSingle_One() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .completed(250)
            ])
        
        let res = await scheduler.start {
            await xs.single()
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 2),
            .completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testSingle_Many() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .completed(250)
            ])
        
        let res = await scheduler.start {
            await xs.single()
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 2),
            .error(220, RxError.moreThanOneElement)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220)
            ])
    }
    
    func testSingle_Error() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .error(210, testError)
            ])
        
        let res = await scheduler.start {
            await xs.single()
        }
        
        XCTAssertEqual(res.events, [
            .error(210, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    #if !DEBUG
    func testSingle_DecrementCountsFirst() {
        let k = BehaviorSubject(value: false)

        _ = k.single { _ in true }.subscribe(onNext: { n in
            k.on(.next(!n))
        })
    }
    #endif
    
    func testSinglePredicate_Empty() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(250)
            ])
        
        let res = await scheduler.start {
            await xs.single { e in
                return e % 2 == 1
            }
        }
        
        XCTAssertEqual(res.events, [
            .error(250, RxError.noElements)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testSinglePredicate_One() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
            ])
        
        let res = await scheduler.start {
            await xs.single { e in
                return e == 4
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(230, 4),
            .completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testSinglePredicate_Many() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
            ])
        
        let res = await scheduler.start {
            await xs.single { e in
                return (e % 2) == 1
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(220, 3),
            .error(240, RxError.moreThanOneElement)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 240)
            ])
    }
    
    func testSinglePredicate_Error() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .error(210, testError)
            ])
        
        let res = await scheduler.start {
            await xs.single { e in
                return e % 2 == 1
            }
        }
        
        XCTAssertEqual(res.events, [
            .error(210, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }
    
    func testSinglePredicate_Throws() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
            ])
        
        let res = await scheduler.start {
            await xs.single { (e: Int) -> Bool in
                guard e < 4 else {
                    throw testError
                }
                return false
            }
        }
        
        XCTAssertEqual(res.events, [
            .error(230, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    #if !DEBUG
        func testSinglePredicate_DecrementCountsFirst() {
            let k = BehaviorSubject(value: false)

            _ = k.single { _ in true }.subscribe(onNext: { n in
                k.on(.next(!n))
            })
        }
    #endif

    #if TRACE_RESOURCES
    func testSingleReleasesResourcesOnComplete() async {
        _ = await Observable<Int>.just(1).single().subscribe()
        }

    func testSinleReleasesResourcesOnError() async {
        _ = await Observable<Int>.error(testError).single().subscribe()
        }
    #endif
}
