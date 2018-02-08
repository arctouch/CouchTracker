import XCTest
import RxTest
import RxSwift
import RealmSwift
import TraktSwift
import RxBlocking

final class ShowsProgressRealmDataSourceTest: XCTestCase {
	private var realmProvider: RealmProvider!
  private var schedulers: TestSchedulers!
  private var dataSource: ShowsProgressRealmDataSource!
  private var observer: TestableObserver<[WatchedShowEntity]>!

	override func setUp() {
		super.setUp()

    var testableConfiguration = Realm.Configuration()
    testableConfiguration.inMemoryIdentifier = self.name

    realmProvider = DefaultRealmProvider(configuration: testableConfiguration)
    schedulers = TestSchedulers()
    dataSource = ShowsProgressRealmDataSource(realmProvider: realmProvider, schedulers: schedulers)
    observer = schedulers.createObserver([WatchedShowEntity].self)
	}

  override func tearDown() {
//    let realm = realmProvider.realm
//    try! realm.write {
//      realmProvider.realm.deleteAll()
//    }

//    realmProvider = nil
//    schedulers = nil
//    dataSource = nil
//    observer = nil

    super.tearDown()
  }

  func testShowProgressRealmDataSource_addEntity_successful() {
    //Given

    //When
    let appEntity = ShowsProgressMocks.mockWatchedShowEntity()
    try! dataSource.addWatched(shows: [appEntity])

    //Then
    let results = realmProvider.realm.objects(WatchedShowEntityRealm.self)
    let expectedRealmEntity = appEntity.toRealm()

    XCTAssertEqual([expectedRealmEntity], results.toArray())
  }

  func testShowProgressRealmDataSource_fetchRealmObjectWithEmptyDataSource_emitsEmptyShows() {
    //Given

    //When
    _ = dataSource.fetchWatchedShows().subscribe(observer)
    schedulers.start()

    //Then
    let expectedEvents = [next(0, [WatchedShowEntity]())]
    RXAssertEvents(observer, expectedEvents)
  }

  func testShowProgressRealmDataSource_fetchRealmObject_asAppEntities() {
    //Given
    let showIds = ShowIdsRealm()
    showIds.imdb = "imdb-id"
    showIds.slug = "show-slug"
    showIds.tmdb.value = nil
    showIds.trakt = 1020
    showIds.tvdb = 3030
    showIds.tvrage.value = 1001

    let realmShowEntity = ShowEntityRealm()
    realmShowEntity.firstAired = Date(timeIntervalSince1970: 0)
    realmShowEntity.network = "ABC"
    realmShowEntity.overview = "Cool show"
    realmShowEntity.status = "returning series"
    realmShowEntity.title = "Title"
    realmShowEntity.ids = showIds

    let episodeIds = EpisodeIdsRealm()
    episodeIds.imdb = nil
    episodeIds.tmdb.value = 11
    episodeIds.trakt = 3050
    episodeIds.tvdb = 6021
    episodeIds.tvrage.value = nil

    let nextEpisodeEntity = EpisodeEntityRealm()
    nextEpisodeEntity.firstAired = Date(timeIntervalSince1970: 0)
    nextEpisodeEntity.lastWatched = Date(timeIntervalSince1970: 6)
    nextEpisodeEntity.number = 4
    nextEpisodeEntity.season = 1
    nextEpisodeEntity.showIds = showIds
    nextEpisodeEntity.overview = "TBD"
    nextEpisodeEntity.title = "What?"
    nextEpisodeEntity.ids = episodeIds

    let realmEntity = WatchedShowEntityRealm()
    realmEntity.aired = 5
    realmEntity.completed = 3
    realmEntity.lastWatched = Date(timeIntervalSince1970: 6)
    realmEntity.show = realmShowEntity
    realmEntity.nextEpisode = nextEpisodeEntity

    let realm = realmProvider.realm
    try! realm.write {
      realm.add(realmEntity)
    }

    //When
    _ = dataSource.fetchWatchedShows().subscribe(observer)
    schedulers.start()

    //Then
    let expectedShowIds = ShowIds(trakt: 1020, tmdb: nil, imdb: "imdb-id", slug: "show-slug", tvdb: 3030, tvrage: 1001)
    let expectedShowEntity = ShowEntity(ids: expectedShowIds, title: "Title", overview: "Cool show", network: "ABC",
                                        genres: [Genre](), status: Status.returning, firstAired: Date(timeIntervalSince1970: 0))
    let expectedEpisodeIds = EpisodeIds(trakt: 3050, tmdb: 11, imdb: nil, tvdb: 6021, tvrage: nil)
    let expectedNextEpisode = EpisodeEntity(ids: expectedEpisodeIds, showIds: expectedShowIds, title: "What?",
                                            overview: "TBD", number: 4, season: 1,
                                            firstAired: Date(timeIntervalSince1970: 0),
                                            lastWatched: Date(timeIntervalSince1970: 6))
    let expectedEntity = WatchedShowEntity(show: expectedShowEntity, aired: 5, completed: 3, nextEpisode: expectedNextEpisode, lastWatched: Date(timeIntervalSince1970: 6))

    let expectedEvents = [next(0, [expectedEntity])]

    RXAssertEvents(observer.events, expectedEvents)
  }

  func testShowProgressRealmDataSource_emitsNextWhenAddNewEntity() {
    /*

     I don't know how to make this test yet.
     I tryed to do like RxRealm tests
     https://github.com/RxSwiftCommunity/RxRealm/blob/master/Example/RxRealm_Tests/RxRealmObjectTests.swift
     but it doesn't work.
     Using .toBlocking(), it runs infinitely!

     */
  }
}
