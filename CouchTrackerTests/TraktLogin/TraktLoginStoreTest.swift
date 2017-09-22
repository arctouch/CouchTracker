/*
 Copyright 2017 ArcTouch LLC.
 All rights reserved.
 
 This file, its contents, concepts, methods, behavior, and operation
 (collectively the "Software") are protected by trade secret, patent,
 and copyright laws. The use of the Software is governed by a license
 agreement. Disclosure of the Software to third parties, in any form,
 in whole or in part, is expressly prohibited except as authorized by
 the license agreement.
 */

import XCTest
import RxSwift
import RxTest

final class TraktLoginStoreTest: XCTestCase {
  private let scheduler = TestScheduler(initialClock: 0)
  private var observer: TestableObserver<TraktLoginState>!

  override func setUp() {
    observer = scheduler.createObserver(TraktLoginState.self)
    super.setUp()
  }

  func testTraktLoginStore_alreadyAuthenticated_emitsLogged() {
    //Given
    let trakt = TraktProviderMock(oauthURL: URL(string: "http://google.com")!, error: nil)
    let store: TraktLoginObservable = TraktLoginStore(trakt: trakt)

    //When
    _ = store.observe().subscribe(observer)

    //Then
    let expectedEvents = [next(0, TraktLoginState.logged)]
    XCTAssertEqual(observer.events, expectedEvents)
  }

  func testTraktLoginStore_notAuthenticated_emitsNotLogged() {
    //Given
    let trakt = TraktProviderMock()
    let store: TraktLoginObservable = TraktLoginStore(trakt: trakt)

    //When
    _ = store.observe().subscribe(observer)

    //Then
    let expectedEvents = [next(0, TraktLoginState.notLogged)]
    XCTAssertEqual(observer.events, expectedEvents)
  }

  func testTraktLoginStore_notifyLoginStatusChanges() {
    //Given
    let trakt = TraktProviderMock()
    let store = TraktLoginStore(trakt: trakt)
    let output: TraktLoginOutput = store.loginOutput
    let loginObservable: TraktLoginObservable = store

    ///When
    _ = loginObservable.observe().subscribe(observer)
    output.loggedInSuccessfully()
    output.logInFail(message: "Wrong user or password")
    output.logInFail(message: "Wrong user or password")
    output.loggedInSuccessfully()
    output.loggedInSuccessfully()

    //Then
    let expectedEvents = [next(0, TraktLoginState.notLogged),
                          next(0, TraktLoginState.logged),
                          next(0, TraktLoginState.notLogged),
                          next(0, TraktLoginState.notLogged),
                          next(0, TraktLoginState.logged),
                          next(0, TraktLoginState.logged)]

    XCTAssertEqual(observer.events, expectedEvents)
  }
}