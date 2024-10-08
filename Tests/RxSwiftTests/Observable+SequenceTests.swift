//
//  Observable+SequenceTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableSequenceTest : RxTest {
}

extension ObservableSequenceTest {
    func testFromArray_complete_immediate() async {
        let scheduler = await TestScheduler(initialClock: 0)
        let res = await scheduler.start {
            await Observable.from([3, 1, 2, 4], scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(201, 3),
            .next(202, 1),
            .next(203, 2),
            .next(204, 4),
            .completed(205)
            ])
    }

    func testFromArray_complete() async {
        let scheduler = await TestScheduler(initialClock: 0)
        let res = await scheduler.start {
            await Observable.from([3, 1, 2, 4], scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(201, 3),
            .next(202, 1),
            .next(203, 2),
            .next(204, 4),
            .completed(205)
            ])
    }

    func testFromArray_dispose() async {
        let scheduler = await TestScheduler(initialClock: 0)
        let res = await scheduler.start(disposed: 203) {
            await Observable.from([3, 1, 2, 4], scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(201, 3),
            .next(202, 1),
            ])
    }

    #if TRACE_RESOURCES
    func testFromArrayReleasesResourcesOnComplete() async {
        let testScheduler = await TestScheduler(initialClock: 0)
        _ = await Observable.from([1], scheduler: testScheduler).subscribe()
        await testScheduler.start()
        }
    #endif
}

extension ObservableSequenceTest {
    func testSequenceOf_complete_immediate() async {
        let scheduler = await TestScheduler(initialClock: 0)
        let res = await scheduler.start {
            await Observable.of(3, 1, 2, 4)
        }

        XCTAssertEqual(res.events, [
            .next(200, 3),
            .next(200, 1),
            .next(200, 2),
            .next(200, 4),
            .completed(200)
            ])
    }

    func testSequenceOf_complete() async {
        let scheduler = await TestScheduler(initialClock: 0)
        let res = await scheduler.start {
            await Observable.of(3, 1, 2, 4, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(201, 3),
            .next(202, 1),
            .next(203, 2),
            .next(204, 4),
            .completed(205)
            ])
    }

    func testSequenceOf_dispose() async {
        let scheduler = await TestScheduler(initialClock: 0)
        let res = await scheduler.start(disposed: 203) {
            await Observable.of(3, 1, 2, 4, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(201, 3),
            .next(202, 1),
            ])
    }

    #if TRACE_RESOURCES
    func testOfReleasesResourcesOnComplete() async {
        let testScheduler = await TestScheduler(initialClock: 0)
        _ = await Observable<Int>.of(11, scheduler: testScheduler).subscribe()
        await testScheduler.start()
        }
    #endif
}

extension ObservableSequenceTest {
    func testFromAnySequence_basic_immediate() async {
        let scheduler = await TestScheduler(initialClock: 0)
        let res = await scheduler.start {
            await Observable.from(AnySequence([3, 1, 2, 4]), scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(201, 3),
            .next(202, 1),
            .next(203, 2),
            .next(204, 4),
            .completed(205)
            ])
    }

    func testToObservableAnySequence_basic_testScheduler() async {
        let scheduler = await TestScheduler(initialClock: 0)
        let res = await scheduler.start {
            await Observable.from(AnySequence([3, 1, 2, 4]), scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(201, 3),
            .next(202, 1),
            .next(203, 2),
            .next(204, 4),
            .completed(205)
            ])
    }

    #if TRACE_RESOURCES
    func testFromSequenceReleasesResourcesOnComplete() async {
        let testScheduler = await TestScheduler(initialClock: 0)
        _ = await Observable<Int>.from(AnySequence([3, 1, 2, 4]), scheduler: testScheduler).subscribe()
        await testScheduler.start()
        }
    #endif
}
