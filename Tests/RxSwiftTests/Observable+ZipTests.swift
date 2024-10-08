//
//  Observable+ZipTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 3/5/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableZipTest : RxTest {
}

extension ObservableZipTest {
    func testZip_NeverEmpty() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let n = await scheduler.createHotObservable([
            .next(150, 1)
        ])

        let e = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(210)
        ])

        let res = await scheduler.start {
            await Observable.zip(n, e) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [])

        XCTAssertEqual(n.subscriptions, [
            Subscription(200, 1000)
        ])

        XCTAssertEqual(e.subscriptions, [
            Subscription(200, 210)
        ])
    }

    func testZip_EmptyNever() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let n = await scheduler.createHotObservable([
            .next(150, 1)
        ])

        let e = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(210)
        ])

        let res = await scheduler.start {
            await Observable.zip(e, n) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [])

        XCTAssertEqual(n.subscriptions, [
            Subscription(200, 1000)
        ])

        XCTAssertEqual(e.subscriptions, [
            Subscription(200, 210)
        ])
    }

    func testZip_EmptyNonEmpty() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let e = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(210)
        ])

        let o = await scheduler.createHotObservable([
            .next(150, 1),
            .next(215, 2),
            .completed(220)
        ])

        let res = await scheduler.start {
            await Observable.zip(e, o) { $0 + $1 }
        }
   
        let messages = [
            Recorded.completed(220, Int.self)
        ]
        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(e.subscriptions, [
            Subscription(200, 210)
        ])

        XCTAssertEqual(o.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_NonEmptyEmpty() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let e = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(210)
        ])

        let o = await scheduler.createHotObservable([
            .next(150, 1),
            .next(215, 2),
            .completed(220)
        ])

        let res = await scheduler.start {
            await Observable.zip(o, e) { $0 + $1 }
        }
   
        let messages = [
            Recorded.completed(220, Int.self)
        ]
        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(e.subscriptions, [
            Subscription(200, 210)
        ])

        XCTAssertEqual(o.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_NeverNonEmpty() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let n = await scheduler.createHotObservable([
            .next(150, 1),
        ])

        let o = await scheduler.createHotObservable([
            .next(150, 1),
            .next(215, 2),
            .completed(220)
        ])

        let res = await scheduler.start {
            await Observable.zip(n, o) { $0 + $1 }
        }
   
        let messages: [Recorded<Event<Int>>] = []
        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(n.subscriptions, [
            Subscription(200, 1000)
        ])
    }

    func testZip_NonEmptyNever() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let n = await scheduler.createHotObservable([
            .next(150, 1),
        ])

        let o = await scheduler.createHotObservable([
            .next(150, 1),
            .next(215, 2),
            .completed(220)
        ])

        let res = await scheduler.start {
            await Observable.zip(o, n) { $0 + $1 }
        }
   
        let messages: [Recorded<Event<Int>>] = []
        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(n.subscriptions, [
            Subscription(200, 1000)
        ])
    }

    func testZip_NonEmptyNonEmpty() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let o1 = await scheduler.createHotObservable([
            .next(150, 1),
            .next(215, 2),
            .completed(230)
        ])

        let o2 = await scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 3),
            .completed(240)
        ])

        let res = await scheduler.start {
            await Observable.zip(o1, o2) { $0 + $1 }
        }
   
        let messages = Recorded.events(
            .next(220, 2 + 3),
            .completed(240)
        )

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 230)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 240)
        ])
    }

    func testZip_EmptyError() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let o1 = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(230)
        ])

        let o2 = await scheduler.createHotObservable([
            .next(150, 1),
            .error(220, testError)
        ])

        let res = await scheduler.start {
            await Observable.zip(o1, o2) { $0 + $1 }
        }
   
        let messages = [
            Recorded.error(220, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_ErrorEmpty() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let o1 = await scheduler.createHotObservable([
            .next(150, 1),
            .completed(230)
        ])

        let o2 = await scheduler.createHotObservable([
            .next(150, 1),
            .error(220, testError)
        ])

        let res = await scheduler.start {
            await Observable.zip(o2, o1) { $0 + $1 }
        }
   
        let messages = [
            Recorded.error(220, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_NeverError() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let o1 = await scheduler.createHotObservable([
            .next(150, 1),
        ])

        let o2 = await scheduler.createHotObservable([
            .next(150, 1),
            .error(220, testError)
        ])

        let res = await scheduler.start {
            await Observable.zip(o1, o2) { $0 + $1 }
        }
   
        let messages = [
            Recorded.error(220, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_ErrorNever() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let o1 = await scheduler.createHotObservable([
            .next(150, 1),
        ])

        let o2 = await scheduler.createHotObservable([
            .next(150, 1),
            .error(220, testError)
        ])

        let res = await scheduler.start {
            await Observable.zip(o2, o1) { $0 + $1 }
        }
   
        let messages = [
            Recorded.error(220, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_ErrorError() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let o1 = await scheduler.createHotObservable([
            .next(150, 1),
            .error(230, testError1)
        ])

        let o2 = await scheduler.createHotObservable([
            .next(150, 1),
            .error(220, testError2)
        ])

        let res = await scheduler.start {
            await Observable.zip(o2, o1) { $0 + $1 }
        }
   
        let messages = [
            Recorded.error(220, testError2, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_SomeError() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let o1 = await scheduler.createHotObservable([
            .next(150, 1),
            .next(215, 2),
            .completed(230)
        ])

        let o2 = await scheduler.createHotObservable([
            .next(150, 1),
            .error(220, testError1)
        ])

        let res = await scheduler.start {
            await Observable.zip(o1, o2) { $0 + $1 }
        }
   
        let messages = [
            Recorded.error(220, testError1, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_ErrorSome() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let o1 = await scheduler.createHotObservable([
            .next(150, 1),
            .next(215, 2),
            .completed(230)
        ])

        let o2 = await scheduler.createHotObservable([
            .next(150, 1),
            .error(220, testError1)
        ])

        let res = await scheduler.start {
            await Observable.zip(o2, o1) { $0 + $1 }
        }
   
        let messages = [
            Recorded.error(220, testError1, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_LeftCompletesFirst() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let o1 = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .completed(220)
        ])

        let o2 = await scheduler.createHotObservable([
            .next(150, 1),
            .next(215, 4),
            .completed(225)
        ])

        let res = await scheduler.start {
            await Observable.zip(o1, o2) { $0 + $1 }
        }
   
        let messages = Recorded.events(
            .next(215, 2 + 4),
            .completed(225)
        )

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 225)
        ])
    }

    func testZip_RightCompletesFirst() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let o1 = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .completed(220)
        ])

        let o2 = await scheduler.createHotObservable([
            .next(150, 1),
            .next(215, 4),
            .completed(225)
        ])

        let res = await scheduler.start {
            await Observable.zip(o2, o1) { $0 + $1 }
        }
   
        let messages = Recorded.events(
            .next(215, 2 + 4),
            .completed(225)
        )

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 225)
        ])
    }

    func testZip_LeftTriggersSelectorError() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let o1 = await scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .completed(220)
        ])

        let o2 = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 4),
        ])

        let res = await scheduler.start {
            await Observable.zip(o1, o2) { (_, _) throws -> Int in throw testError }
        }
   
        let messages = [
            Recorded.error(220, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_RightTriggersSelectorError() async {
        let scheduler = await TestScheduler(initialClock: 0)

        let o1 = await scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .completed(220)
        ])

        let o2 = await scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 4),
        ])

        let res = await scheduler.start {
            await Observable.zip(o2, o1) { (_, _) throws -> Int in throw testError }
        }
   
        let messages = [
            Recorded.error(220, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    #if TRACE_RESOURCES
    func testZipReleasesResourcesOnComplete1() async {
        _ = await Observable.zip(Observable.just(1), Observable.just(1), resultSelector: +).subscribe()
        }

    func testZipReleasesResourcesOnError1() async {
        _ = await Observable.zip(Observable.just(1), Observable<Int>.error(testError), resultSelector: +).subscribe()
        }

    func testZipReleasesResourcesOnComplete2() async {
        _ = await Observable.zip(Observable.just(1), Observable.just(1)).subscribe()
        }

    func testZipReleasesResourcesOnError2() async {
        _ = await Observable.zip(Observable.just(1), Observable<Int>.error(testError)).subscribe()
        }

    #endif
}

extension ObservableZipTest {
    func testZip_NAry_emptyArray() async {
        let factories: [() async -> Observable<EquatableArray<Int>>] =
            [
                { await Observable.zip(([] as [Observable<Int>]).map { $0.asObservable() }) { EquatableArray($0) } },
                { await Observable.zip(([] as [Observable<Int>]).map { $0.asObservable() }).map { EquatableArray($0) } },
                ]

        for factory in factories {
            let scheduler = await TestScheduler(initialClock: 0)

            let res = await scheduler.start {
                await factory()
            }

            XCTAssertEqual(res.events, [
                .completed(200)
                ])
        }
    }
    
    func testZip_NAry_symmetric() async {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>) async -> Observable<EquatableArray<Int>>] =
            [
                { e0, e1, e2 in await Observable.zip([e0, e1, e2].map { await $0.asObservable() }) { EquatableArray($0) } },
                { e0, e1, e2 in await Observable.zip([e0, e1, e2].map { await $0.asObservable() }).map { EquatableArray($0) } },
            ]

        for factory in factories {
            let scheduler = await TestScheduler(initialClock: 0)

            let e0 = await scheduler.createHotObservable([
                .next(150, 1),
                .next(210, 1),
                .next(250, 4),
                .completed(420)
                ])
            let e1 = await scheduler.createHotObservable([
                .next(150, 1),
                .next(220, 2),
                .next(240, 5),
                .completed(410)
                ])
            let e2 = await scheduler.createHotObservable([
                .next(150, 1),
                .next(230, 3),
                .next(260, 6),
                .completed(400)
                ])
            
            let res = await scheduler.start {
                await factory(e0, e1, e2)
            }
            
            XCTAssertEqual(res.events, [
                .next(230, EquatableArray([1, 2, 3])),
                .next(260, EquatableArray([4, 5, 6])),
                .completed(420)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 420)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 410)])
            XCTAssertEqual(e2.subscriptions, [Subscription(200, 400)])
        }
    }
    
    func testZip_NAry_asymmetric() async {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>) async -> Observable<EquatableArray<Int>>] =
            [
                { e0, e1, e2 in await Observable.zip([e0, e1, e2].map { await $0.asObservable() }) { EquatableArray($0) } },
                { e0, e1, e2 in await Observable.zip([e0, e1, e2].map { await $0.asObservable() }).map { EquatableArray($0) } },
            ]

        for factory in factories {
            let scheduler = await TestScheduler(initialClock: 0)

            let e0 = await scheduler.createHotObservable([
                .next(150, 1),
                .next(210, 1),
                .next(250, 4),
                .completed(270)
                ])
            let e1 = await scheduler.createHotObservable([
                .next(150, 1),
                .next(220, 2),
                .next(240, 5),
                .next(290, 7),
                .next(310, 9),
                .completed(410)
                ])
            let e2 = await scheduler.createHotObservable([
                .next(150, 1),
                .next(230, 3),
                .next(260, 6),
                .next(280, 8),
                .completed(300)
                ])
            
            let res = await scheduler.start {
                await factory(e0, e1, e2)
            }
            
            XCTAssertEqual(res.events, [
                .next(230, EquatableArray([1, 2, 3])),
                .next(260, EquatableArray([4, 5, 6])),
                .completed(310)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 270)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 310)])
            XCTAssertEqual(e2.subscriptions, [Subscription(200, 300)])
        }
    }
    
    func testZip_NAry_error() async {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>) async -> Observable<EquatableArray<Int>>] =
            [
                { e0, e1, e2 in await Observable.zip([e0, e1, e2].map { await $0.asObservable() }) { EquatableArray($0) } },
                { e0, e1, e2 in await Observable.zip([e0, e1, e2].map { await $0.asObservable() }).map { EquatableArray($0) } },
            ]

        for factory in factories {
            let scheduler = await TestScheduler(initialClock: 0)

            let e0 = await scheduler.createHotObservable([
                .next(150, 1),
                .next(210, 1),
                .error(250, testError),
                ])
            let e1 = await scheduler.createHotObservable([
                .next(150, 1),
                .next(220, 2),
                .next(240, 5),
                .completed(410)
                ])
            let e2 = await scheduler.createHotObservable([
                .next(150, 1),
                .next(230, 3),
                .next(260, 6),
                .completed(400)
                ])
            
            let res = await scheduler.start {
                await factory(e0, e1, e2)
            }
            
            XCTAssertEqual(res.events, [
                .next(230, EquatableArray([1, 2, 3])),
                .error(250, testError)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 250)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
            XCTAssertEqual(e2.subscriptions, [Subscription(200, 250)])
        }
    }
    
    func testZip_NAry_atLeastOneErrors4() async {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>) async
            -> Observable<Int>] =
            [
                { e0, e1, e2, e3 in await Observable.zip([e0, e1, e2, e3].map { await $0.asObservable() }) { _ in 42 } },
                { e0, e1, e2, e3 in await Observable.zip([e0, e1, e2, e3].map { await $0.asObservable() }).map { _ in 42 } },
            ]

        for factory in factories {
            let scheduler = await TestScheduler(initialClock: 0)

            let e0 = await scheduler.createHotObservable([
                .next(150, 1),
                .next(210, 1),
                .completed(400)
                ])
            let e1 = await scheduler.createHotObservable([
                .next(150, 1),
                .next(220, 2),
                .completed(400)
                ])
            let e2 = await scheduler.createHotObservable([
                .next(150, 1),
                .error(230, testError)
                ])
            let e3 = await scheduler.createHotObservable([
                .next(150, 1),
                .next(240, 4),
                .completed(400)
                ])
            
            let res = await scheduler.start {
                await factory(e0, e1, e2, e3)
            }
            
            XCTAssertEqual(res.events, [
                .error(230, testError)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e2.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e3.subscriptions, [Subscription(200, 230)])
        }
    }

    #if TRACE_RESOURCES
    func testZipArrayReleasesResourcesOnComplete1() async {
        _ = await Observable.zip([Observable.just(1), Observable.just(1)]) { $0.reduce(0, +) }.subscribe()
        }

    func testZipArrayReleasesResourcesOnError1() async {
        _ = await Observable.zip([Observable<Int>.error(testError), Observable.just(1)]) { $0.reduce(0, +) }.subscribe()
        }

    func testZipArrayReleasesResourcesOnComplete2() async {
        _ = await Observable.zip([Observable.just(1), Observable.just(1)]).subscribe()
        }

    func testZipArrayReleasesResourcesOnError2() async {
        _ = await Observable.zip([Observable<Int>.error(testError), Observable.just(1)]).subscribe()
        }
    #endif
}


