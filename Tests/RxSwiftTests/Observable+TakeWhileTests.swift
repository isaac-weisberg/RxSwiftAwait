//
//  Observable+TakeWhileTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableTakeWhileTest : RxTest {
}

extension ObservableTakeWhileTest {
    func testTakeWhile_Exclusive_Complete_Before() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .completed(330),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .completed(600)
        ])
        
        var invoked = 0
        
        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .exclusive)
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .completed(330)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 330)
        ])
        
        XCTAssertEqual(4, invoked)
    }
    
    func testTakeWhile_Exclusive_Complete_After() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .completed(600)
            ])
        
        var invoked = 0
        
        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .exclusive)
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .completed(390)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testTakeWhile_Exclusive_Error_Before() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .error(270, testError),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .completed(600)
            ])
        
        var invoked = 0
        
        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .exclusive)
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .error(270, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 270)
            ])
        
        XCTAssertEqual(2, invoked)
    }
    
    func testTakeWhile_Exclusive_Error_After() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .error(600, testError),
            ])
        
        var invoked = 0
        
        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .exclusive)
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .completed(390)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testTakeWhile_Exclusive_Dispose_Before() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .error(600, testError),
            ])
        
        var invoked = 0
        
        let res = await scheduler.start(disposed: 300) { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .exclusive)
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .next(290, 13)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(3, invoked)
    }
    
    func testTakeWhile_Exclusive_Dispose_After() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .error(600, testError),
            ])
        
        var invoked = 0
        
        let res = await scheduler.start(disposed: 400) { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .exclusive)
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .completed(390)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testTakeWhile_Exclusive_Zero() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(205, 100),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .error(600, testError),
            ])
        
        var invoked = 0
        
        let res = await scheduler.start(disposed: 300) { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .exclusive)
        }
        
        XCTAssertEqual(res.events, [
            .completed(205)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 205)
            ])
        
        XCTAssertEqual(1, invoked)
    }
    
    func testTakeWhile_Exclusive_Throw() async {
        let scheduler = await TestScheduler(initialClock: 0)
 
        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .completed(600)
            ])
        
        var invoked = 0
        
        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.take(while: { num in
                invoked += 1
                
                if invoked == 3 {
                    throw testError
                }
                
                return isPrime(num)
            }, behavior: .exclusive)
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .error(290, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
            ])
        
        XCTAssertEqual(3, invoked)
    }

    func testTakeWhile_Inclusive_Complete_Before() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .completed(330),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .completed(600)
        ])

        var invoked = 0

        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .inclusive)
        }

        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .completed(330)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 330)
        ])

        XCTAssertEqual(4, invoked)
    }

    func testTakeWhile_Inclusive_Complete_After() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .completed(600)
            ])

        var invoked = 0

        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .inclusive)
        }

        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .completed(390)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])

        XCTAssertEqual(6, invoked)
    }

    func testTakeWhile_Inclusive_Error_Before() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .error(270, testError),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .completed(600)
            ])

        var invoked = 0

        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .inclusive)
        }

        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .error(270, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 270)
            ])

        XCTAssertEqual(2, invoked)
    }

    func testTakeWhile_Inclusive_Error_After() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .error(600, testError),
            ])

        var invoked = 0

        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .inclusive)
        }

        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .completed(390)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])

        XCTAssertEqual(6, invoked)
    }

    func testTakeWhile_Inclusive_Dispose_Before() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .error(600, testError),
            ])

        var invoked = 0

        let res = await scheduler.start(disposed: 300) { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .inclusive)
        }

        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .next(290, 13)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])

        XCTAssertEqual(3, invoked)
    }

    func testTakeWhile_Inclusive_Dispose_After() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .error(600, testError),
            ])

        var invoked = 0

        let res = await scheduler.start(disposed: 400) { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .inclusive)
        }

        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .completed(390)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])

        XCTAssertEqual(6, invoked)
    }

    func testTakeWhile_Inclusive_Zero() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(205, 100),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .error(600, testError),
            ])

        var invoked = 0

        let res = await scheduler.start(disposed: 300) { () -> Observable<Int> in
            return await xs.take(while: { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }, behavior: .inclusive)
        }

        XCTAssertEqual(res.events, [
            .next(205, 100),
            .completed(205)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 205)
            ])

        XCTAssertEqual(1, invoked)
    }

    func testTakeWhile_Inclusive_Throw() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let xs = await scheduler.createHotObservable([
            .next(90, -1),
            .next(110, -1),
            .next(210, 2),
            .next(260, 5),
            .next(290, 13),
            .next(320, 3),
            .next(350, 7),
            .next(390, 4),
            .next(410, 17),
            .next(450, 8),
            .next(500, 23),
            .completed(600)
            ])

        var invoked = 0

        let res = await scheduler.start { () -> Observable<Int> in
            return await xs.take(while: { num in
                invoked += 1

                if invoked == 3 {
                    throw testError
                }

                return isPrime(num)
            }, behavior: .inclusive)
        }

        XCTAssertEqual(res.events, [
            .next(210, 2),
            .next(260, 5),
            .error(290, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
            ])

        XCTAssertEqual(3, invoked)
    }
    

    #if TRACE_RESOURCES
    func testTakeWhileReleasesResourcesOnComplete() async {
        _ = await Observable<Int>.just(1).take(while: { _ in true }).subscribe()
    }

    func testTakeWhile1ReleasesResourcesOnError() async {
        _ = await Observable<Int>.error(testError).take(while: { _ in true }).subscribe()
    }

    func testTakeWhile2ReleasesResourcesOnError() async {
        _ = await Observable<Int>.just(1).take(while: { _ -> Bool in throw testError }).subscribe()
    }
    #endif
}
