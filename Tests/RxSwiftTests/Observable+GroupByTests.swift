//
//  Observable+GroupByTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableGroupByTest : RxTest {
}

extension ObservableGroupByTest {
    func testGroupBy_TwoGroup() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(205, 1),
            .next(210, 2),
            .next(240, 3),
            .next(280, 4),
            .next(320, 5),
            .next(350, 6),
            .next(370, 7),
            .next(420, 8),
            .next(470, 9),
            .completed(600)
            ])
        
        let res = await scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<Int, Int>> = await xs.groupBy { x in x % 2 }
            let mappedWithIndex = await group.enumerated().map { (i: Int, go: GroupedObservable<Int, Int>) -> Observable<String> in
                return await go.map { (e: Int) -> String in
                    return "\(i) \(e)"
                }
            }
            let result = await mappedWithIndex.merge()
            return result
        }
        
        XCTAssertEqual(res.events, [
            .next(205, "0 1"),
            .next(210, "1 2"),
            .next(240, "0 3"),
            .next(280, "1 4"),
            .next(320, "0 5"),
            .next(350, "1 6"),
            .next(370, "0 7"),
            .next(420, "1 8"),
            .next(470, "0 9"),
            .completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testGroupBy_OuterComplete() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        var keyInvoked = 0
        
        let xs = await scheduler.createHotObservable([
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(270, "baR  "),
            .next(310, "foO "),
            .next(350, " Baz   "),
            .next(360, "  qux "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .next(470, "FOO "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .next(530, "    fOo    "),
            .completed(570),
            .next(580, "error"),
            .completed(600),
            .error(650, testError)
            ])
        
        let res = await scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<String, String>> = await xs.groupBy { x in
                keyInvoked += 1
                if x == "error" { throw testError }

                return x.lowercased().trimWhitespace()
            }
            return await group.map { (go: GroupedObservable<String, String>) -> String in
                return go.key
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(220, "foo"),
            .next(270, "bar"),
            .next(350, "baz"),
            .next(360, "qux"),
            .completed(570)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
        
        XCTAssertEqual(keyInvoked, 12)
    }
    
    func testGroupBy_OuterError() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        var keyInvoked = 0
        
        let xs = await scheduler.createHotObservable([
            .next(90, "abc"),
            .next(110, "zoo"),
            .next(130, "oof"),
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(270, "baR  "),
            .next(310, "foO "),
            .next(350, " Baz   "),
            .next(360, "  qux "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .next(470, "FOO "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .next(530, "    fOo    "),
            .error(570, testError),
            .completed(600),
            .error(650, testError)
            ])
        
        let res = await scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<String, String>> = await xs.groupBy { x in
                keyInvoked += 1
                if x == "error" { throw testError }

                return x.lowercased().trimWhitespace()
            }
            return await group.map { (go: GroupedObservable<String, String>) -> String in
                return go.key
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(220, "foo"),
            .next(270, "bar"),
            .next(350, "baz"),
            .next(360, "qux"),
            .error(570, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
        
        XCTAssertEqual(keyInvoked, 12)
    }

    
    func testGroupBy_OuterDispose() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        var keyInvoked = 0
        
        let xs = await scheduler.createHotObservable([
            .next(90, "abc"),
            .next(110, "zoo"),
            .next(130, "oof"),
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(270, "baR  "),
            .next(310, "foO "),
            .next(350, " Baz   "),
            .next(360, "  qux "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .next(470, "FOO "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .next(530, "    fOo    "),
            .completed(570),
            .next(580, "error"),
            .completed(600),
            .error(650, testError)
            ])
        
        let res = await scheduler.start(disposed: 355) { () -> Observable<String> in
            let group: Observable<GroupedObservable<String, String>> = await xs.groupBy { x in
                keyInvoked += 1
                if x == "error" { throw testError }

                return x.lowercased().trimWhitespace()
            }
            return await group.map { (go: GroupedObservable<String, String>) -> String in
                return go.key
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(220, "foo"),
            .next(270, "bar"),
            .next(350, "baz")
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 355)
            ])
        
        XCTAssertEqual(keyInvoked, 5)
    }
    
    func testGroupBy_OuterKeySelectorThrows() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        var keyInvoked = 0
        
        let xs = await scheduler.createHotObservable([
            .next(90, "abc"),
            .next(110, "zoo"),
            .next(130, "oof"),
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(270, "baR  "),
            .next(310, "foO "),
            .next(350, " Baz   "),
            .next(360, "  qux "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .next(470, "FOO "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .next(530, "    fOo    "),
            .completed(570),
            .next(580, "error"),
            .completed(600),
            .error(650, testError)
            ])
        
        let res = await scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<String, String>> = await xs.groupBy { x in
                keyInvoked += 1
                if x == "error" { throw testError }

                if keyInvoked == 10 {
                    throw testError
                }
                return x.lowercased().trimWhitespace()
            }
            return await group.map { (go: GroupedObservable<String, String>) -> String in
                return go.key
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(220, "foo"),
            .next(270, "bar"),
            .next(350, "baz"),
            .next(360, "qux"),
            .error(480, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 480)
            ])
        
        XCTAssertEqual(keyInvoked, 10)
    }
    
    func testGroupBy_InnerComplete() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, "abc"),
            .next(110, "zoo"),
            .next(130, "oof"),
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(270, "baR  "),
            .next(310, "foO "),
            .next(350, " Baz   "),
            .next(360, "  qux "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .next(470, "FOO "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .next(530, "    fOo    "),
            .completed(570),
            .next(580, "error"),
            .completed(600),
            .error(650, testError)
            ])

        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()

        await scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = await xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = await outer.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                let result: TestableObserver<String> = scheduler.createObserver(String.self)
                inners[group.key] = group
                results[group.key] = result
                
                innerSubscriptions[group.key] = await scheduler.scheduleRelative((), dueTime: .seconds(100), action: { _ in
                    await group.subscribe(result)
                })
            })
        }
        
        await scheduler.scheduleAt(Defaults.disposed) {
            await outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                await disposable.dispose()
            }
            
        }
        
        await scheduler.start()

        XCTAssertEqual(inners.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            .next(470, "FOO "),
            .next(530, "    fOo    "),
            .completed(570)])

        XCTAssertEqual(results["bar"]!.events, [
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .completed(570)])

        XCTAssertEqual(results["baz"]!.events, [
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .completed(570)])
        
        XCTAssertEqual(results["qux"]!.events, [
            .completed(570)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
    }
    
    func testGroupBy_InnerCompleteAll() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, "abc"),
            .next(110, "zoo"),
            .next(130, "oof"),
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(270, "baR  "),
            .next(310, "foO "),
            .next(350, " Baz   "),
            .next(360, "  qux "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .next(470, "FOO "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .next(530, "    fOo    "),
            .completed(570),
            .next(580, "error"),
            .completed(600),
            .error(650, testError)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        
        await scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = await xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = await outer.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                let result: TestableObserver<String> = scheduler.createObserver(String.self)
                inners[group.key] = group
                results[group.key] = result
                innerSubscriptions[group.key] = await group.subscribe(result)
            })
        }
        
        await scheduler.scheduleAt(Defaults.disposed) {
            await outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                await disposable.dispose()
            }
        }
        
        await scheduler.start()
        
        XCTAssertEqual(inners.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(310, "foO "),
            .next(470, "FOO "),
            .next(530, "    fOo    "),
            .completed(570)])

        XCTAssertEqual(results["bar"]!.events, [
            .next(270, "baR  "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .completed(570)])
        
        XCTAssertEqual(results["baz"]!.events, [
            .next(350, " Baz   "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .completed(570)])
        
        XCTAssertEqual(results["qux"]!.events, [
            .next(360, "  qux "),
            .completed(570)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerError() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, "abc"),
            .next(110, "zoo"),
            .next(130, "oof"),
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(270, "baR  "),
            .next(310, "foO "),
            .next(350, " Baz   "),
            .next(360, "  qux "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .next(470, "FOO "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .next(530, "    fOo    "),
            .error(570, testError),
            .next(580, "error"),
            .completed(600),
            .error(650, testError)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        
        await scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = await xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = await outer.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                let result: TestableObserver<String> = scheduler.createObserver(String.self)
                inners[group.key] = group
                results[group.key] = result
                
                innerSubscriptions[group.key] = await scheduler.scheduleRelative((), dueTime: .seconds(100), action: { _ in
                    await group.subscribe(result)
                })
            })
        }
        
        await scheduler.scheduleAt(Defaults.disposed) {
            await outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                await disposable.dispose()
            }
        }
        
        await scheduler.start()
        
        XCTAssertEqual(inners.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            .next(470, "FOO "),
            .next(530, "    fOo    "),
            .error(570, testError)])
        
        XCTAssertEqual(results["bar"]!.events, [
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .error(570, testError)])
        
        XCTAssertEqual(results["baz"]!.events, [
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .error(570, testError)])
        
        XCTAssertEqual(results["qux"]!.events, [
            .error(570, testError)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
    }

    func testGroupBy_InnerDispose() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, "abc"),
            .next(110, "zoo"),
            .next(130, "oof"),
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(270, "baR  "),
            .next(310, "foO "),
            .next(350, " Baz   "),
            .next(360, "  qux "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .next(470, "FOO "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .next(530, "    fOo    "),
            .completed(570),
            .next(580, "error"),
            .completed(600),
            .error(650, testError)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        
        await scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = await xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = await outer.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                let result: TestableObserver<String> = scheduler.createObserver(String.self)
                inners[group.key] = group
                results[group.key] = result
                innerSubscriptions[group.key] = await group.subscribe(result)
            })
        }
        
        await scheduler.scheduleAt(400) {
            await outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                await disposable.dispose()
            }
        }
        
        await scheduler.start()
        
        XCTAssertEqual(inners.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(310, "foO ")])
        
        XCTAssertEqual(results["bar"]!.events, [
            .next(270, "baR  "),
            .next(390, "   bar")])
        
        XCTAssertEqual(results["baz"]!.events, [
            .next(350, " Baz   ")])
        
        XCTAssertEqual(results["qux"]!.events, [
            .next(360, "  qux ")])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
    
    func testGroupBy_InnerKeyThrow() async {
        let scheduler = await TestScheduler(initialClock: 0)

        var keyInvoked = 0

        let xs = await scheduler.createHotObservable([
            .next(90, "abc"),
            .next(110, "zoo"),
            .next(130, "oof"),
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(270, "baR  "),
            .next(310, "foO "),
            .next(350, " Baz   "),
            .next(360, "  qux "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .next(470, "FOO "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .next(530, "    fOo    "),
            .completed(570),
            .next(580, "error"),
            .completed(600),
            .error(650, testError)
            ])
        
        var outer: Observable<GroupedObservable<String, String>>?
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        
        await scheduler.scheduleAt(Defaults.created) {
            outer = await xs.groupBy { x in
                keyInvoked += 1
                if x == "error" { throw testError }
                if keyInvoked == 6 {
                    throw testError
                }
                return x.lowercased().trimWhitespace()
            }
        }
        
        await scheduler.scheduleAt(Defaults.subscribed) {
            outerSubscription = await outer!.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                let result: TestableObserver<String> = scheduler.createObserver(String.self)
                inners[group.key] = group
                results[group.key] = result
                
                innerSubscriptions[group.key] = await group.subscribe(result)
            })
        }
        
        await scheduler.scheduleAt(Defaults.disposed) {
            await outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                await disposable.dispose()
            }
        }
        
        await scheduler.start()
        
        XCTAssertEqual(inners.count, 3)
        
        XCTAssertEqual(results["foo"]!.events, [
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(310, "foO "),
            .error(360, testError)])
        
        XCTAssertEqual(results["bar"]!.events, [
            .next(270, "baR  "),
            .error(360, testError)])
        
        XCTAssertEqual(results["baz"]!.events, [
            .next(350, " Baz   "),
            .error(360, testError)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 360)
            ])
    }
    
    func testGroupBy_OuterIndependence() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, "abc"),
            .next(110, "zoo"),
            .next(130, "oof"),
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(270, "baR  "),
            .next(310, "foO "),
            .next(350, " Baz   "),
            .next(360, "  qux "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .next(470, "FOO "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .next(530, "    fOo    "),
            .completed(570),
            .next(580, "error"),
            .completed(600),
            .error(650, testError)
            ])
        
        var outer: Observable<GroupedObservable<String, String>>?
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        let outerResults: TestableObserver<String> = scheduler.createObserver(String.self)
        
        await scheduler.scheduleAt(Defaults.created) {
            outer = await xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
        }
        
        await scheduler.scheduleAt(Defaults.subscribed) {
            outerSubscription = await outer!
                .subscribe(
                    onNext: { (group: GroupedObservable<String, String>) -> Void in
                        await outerResults.onNext(group.key)
                        
                        let result: TestableObserver<String> = scheduler.createObserver(String.self)
                        inners[group.key] = group
                        results[group.key] = result
                        innerSubscriptions[group.key] = await group.subscribe(result)
                    },
                    onError: { e -> Void in
                        await outerResults.onError(e)
                    },
                    onCompleted: {
                        await outerResults.onCompleted()
                    },
                    onDisposed: nil)
        }
        
        await scheduler.scheduleAt(Defaults.disposed) {
            await outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                await disposable.dispose()
            }
        }

        await scheduler.scheduleAt(320) {
            await outerSubscription?.dispose()
        }
        
        await scheduler.start()
        
        XCTAssertEqual(inners.keys.count, 2)
        
        XCTAssertEqual(outerResults.events, [
            .next(220, "foo"),
            .next(270, "bar")])
        
        XCTAssertEqual(results["foo"]!.events, [
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(310, "foO "),
            .next(470, "FOO "),
            .next(530, "    fOo    "),
            .completed(570)])
        
        XCTAssertEqual(results["bar"]!.events, [
            .next(270, "baR  "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .completed(570)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
    }
    
    func testGroupBy_InnerIndependence() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, "abc"),
            .next(110, "zoo"),
            .next(130, "oof"),
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(270, "baR  "),
            .next(310, "foO "),
            .next(350, " Baz   "),
            .next(360, "  qux "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .next(470, "FOO "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .next(530, "    fOo    "),
            .completed(570),
            .next(580, "error"),
            .completed(600),
            .error(650, testError)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        let outerResults: TestableObserver<String> = scheduler.createObserver(String.self)
        
        await scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = await xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = await outer
                .subscribe(
                    onNext: { (group: GroupedObservable<String, String>) -> Void in
                        await outerResults.onNext(group.key)
                        
                        let result: TestableObserver<String> = scheduler.createObserver(String.self)
                        inners[group.key] = group
                        results[group.key] = result
                        innerSubscriptions[group.key] = await group.subscribe(result)
                    },
                    onError: { e -> Void in
                        await outerResults.onError(e)
                    },
                    onCompleted: {
                        await outerResults.onCompleted()
                    },
                    onDisposed: nil)
        }
        
        await scheduler.scheduleAt(Defaults.disposed) {
            await outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                await disposable.dispose()
            }
        }
        
        await scheduler.scheduleAt(320) {
            await innerSubscriptions["foo"]!.dispose()
        }
        
        await scheduler.start()
        
        XCTAssertEqual(inners.keys.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(310, "foO ")])
        
        XCTAssertEqual(results["bar"]!.events, [
            .next(270, "baR  "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .completed(570)])
        
        XCTAssertEqual(results["baz"]!.events, [
            .next(350, " Baz   "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .completed(570)])
        
        XCTAssertEqual(results["qux"]!.events, [
            .next(360, "  qux "),
            .completed(570)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerMultipleIndependence() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(90, "abc"),
            .next(110, "zoo"),
            .next(130, "oof"),
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(270, "baR  "),
            .next(310, "foO "),
            .next(350, " Baz   "),
            .next(360, "  qux "),
            .next(390, "   bar"),
            .next(420, " BAR  "),
            .next(470, "FOO "),
            .next(480, "baz  "),
            .next(510, " bAZ "),
            .next(530, "    fOo    "),
            .completed(570),
            .next(580, "error"),
            .completed(600),
            .error(650, testError)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        let outerResults: TestableObserver<String> = scheduler.createObserver(String.self)
        
        await scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = await xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = await outer
                .subscribe(
                    onNext: { (group: GroupedObservable<String, String>) -> Void in
                        await outerResults.onNext(group.key)
                        
                        let result: TestableObserver<String> = scheduler.createObserver(String.self)
                        inners[group.key] = group
                        results[group.key] = result
                        innerSubscriptions[group.key] = await group.subscribe(result)
                    },
                    onError: { e -> Void in
                        await outerResults.onError(e)
                    },
                    onCompleted: {
                        await outerResults.onCompleted()
                    },
                    onDisposed: nil)
        }
        
        await scheduler.scheduleAt(Defaults.disposed) {
            await outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                await disposable.dispose()
            }
        }
        
        await scheduler.scheduleAt(320) {
            await innerSubscriptions["foo"]!.dispose()
        }
        
        await scheduler.scheduleAt(280) {
            await innerSubscriptions["bar"]!.dispose()
        }

        await scheduler.scheduleAt(355) {
            await innerSubscriptions["baz"]!.dispose()
        }

        await scheduler.scheduleAt(400) { () -> Void in
            await innerSubscriptions["qux"]!.dispose()
        }
        
        await scheduler.start()
        
        XCTAssertEqual(inners.keys.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(310, "foO ")])
        
        XCTAssertEqual(results["bar"]!.events, [
            .next(270, "baR  ")])
        
        XCTAssertEqual(results["baz"]!.events, [
            .next(350, " Baz   ")])
        
        XCTAssertEqual(results["qux"]!.events, [
            .next(360, "  qux ")])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerEscapeComplete() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(310, "foO "),
            .next(470, "FOO "),
            .next(530, "    fOo    "),
            .completed(570)
            ])
        
        let results: TestableObserver<String> = scheduler.createObserver(String.self)
        var outer: Observable<GroupedObservable<String, String>>?
        var outerSubscription: Disposable?
        var inner: GroupedObservable<String, String>?
        var innerSubscription: Disposable?
        
        await scheduler.scheduleAt(Defaults.created) {
            outer = await xs.groupBy { x in
                return x.lowercased().trimWhitespace()
            }
        }
        
        await scheduler.scheduleAt(Defaults.subscribed) {
            outerSubscription = await outer!.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                inner = group
            })
        }
        
        await scheduler.scheduleAt(600) {
            innerSubscription = await inner?.subscribe(results)
        }
        
        await scheduler.scheduleAt(Defaults.disposed) {
            await outerSubscription?.dispose()
            await innerSubscription?.dispose()
        }
        
        await scheduler.start()

        XCTAssertEqual(results.events, [
            .completed(600)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerEscapeError() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(310, "foO "),
            .next(470, "FOO "),
            .next(530, "    fOo    "),
            .error(570, testError)
            ])
        
        let results: TestableObserver<String> = scheduler.createObserver(String.self)
        var outer: Observable<GroupedObservable<String, String>>?
        var outerSubscription: Disposable?
        var inner: GroupedObservable<String, String>?
        var innerSubscription: Disposable?
        
        await scheduler.scheduleAt(Defaults.created) {
            outer = await xs.groupBy { x in
                return x.lowercased().trimWhitespace()
            }
        }
        
        await scheduler.scheduleAt(Defaults.subscribed) {
            outerSubscription = await outer!.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                inner = group
            })
        }
        
        await scheduler.scheduleAt(600) {
            innerSubscription = await inner?.subscribe(results)
        }
        
        await scheduler.scheduleAt(Defaults.disposed) { () -> Void in
            await outerSubscription?.dispose()
            await innerSubscription?.dispose()
        }
        
        await scheduler.start()
        
        XCTAssertEqual(results.events, [
            .error(600, testError)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerEscapeDispose() async {
        let scheduler = await TestScheduler(initialClock: 0)
        
        let xs = await scheduler.createHotObservable([
            .next(220, "  foo"),
            .next(240, " FoO "),
            .next(310, "foO "),
            .next(470, "FOO "),
            .next(530, "    fOo    "),
            .error(570, testError)
            ])
        
        let results: TestableObserver<String> = scheduler.createObserver(String.self)
        var outerSubscription: Disposable?
        var inner: GroupedObservable<String, String>?
        var innerSubscription: Disposable?
        
        await scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = await xs.groupBy { x in
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = await outer.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                inner = group
            })
        }
        
        await scheduler.scheduleAt(400) {
            await outerSubscription?.dispose()
        }

        await scheduler.scheduleAt(600) {
            innerSubscription = await inner?.subscribe(results)
        }

        await scheduler.scheduleAt(Defaults.disposed) {
            await innerSubscription?.dispose()
        }
        
        await scheduler.start()
        
        XCTAssertEqual(results.events, [])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)])
    }

    #if TRACE_RESOURCES
    func testGroupByReleasesResourcesOnComplete() async {
        _ = await Observable<Int>.just(1).groupBy { $0 }.subscribe()
        }

    func testGroupByReleasesResourcesOnError1() async {
        _ = await Observable<Int>.error(testError).groupBy { $0 }.subscribe()
        }

    func testGroupByReleasesResourcesOnError2() async {
        _ = await Observable<Int>.error(testError).groupBy { _ -> Int in throw testError }.subscribe()
        }
    #endif
}

import Foundation

extension String {
    fileprivate func trimWhitespace() -> String {
        self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
