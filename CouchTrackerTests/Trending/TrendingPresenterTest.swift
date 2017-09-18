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

import Moya
import ObjectMapper
import XCTest
import TraktSwift
import RxTest

final class TrendingPresenterTest: XCTestCase {

  private let scheduler = TestScheduler(initialClock: 0)
  let view = TrendingViewMock()
  let router = TrendingRouterMock()
  let dataSource = TrendingDataSourceMock()

  func testTrendingPresenter_fetchMoviesSuccessWithEmptyData_andPresentNothing() {
    let repository = EmptyTrendingRepositoryMock()
    let interactor = TrendingServiceMock(repository: repository, imageRepository: imageRepositoryMock)
    let presenter = TrendingiOSPresenter(view: view, interactor: interactor, router: router, dataSource: dataSource)

    presenter.viewDidLoad()

    XCTAssertTrue(view.invokedShowEmptyView)
    XCTAssertFalse(view.invokedShow)
  }

  func testTrendingPresenter_fetchShowsSuccessWithEmptyData_andPresentNothing() {
    let repository = EmptyTrendingRepositoryMock()
    let interactor = TrendingServiceMock(repository: repository, imageRepository: imageRepositoryMock)
    let presenter = TrendingiOSPresenter(view: view, interactor: interactor, router: router, dataSource: dataSource)

    presenter.currentTrendingType.value = .shows
    presenter.viewDidLoad()

    XCTAssertTrue(view.invokedShowEmptyView)
    XCTAssertFalse(view.invokedShow)
    XCTAssertFalse(dataSource.invokedSetViewModels)
    XCTAssertTrue(dataSource.viewModels.isEmpty)
  }

  func testTrendingPresenter_fetchMoviesFailure_andPresentError() {
    let error = TrendingError.parseError("Invalid json")
    let repository = ErrorTrendingRepositoryMock(error: error)
    let interactor = TrendingServiceMock(repository: repository, imageRepository: imageRepositoryMock)
    let presenter = TrendingiOSPresenter(view: view, interactor: interactor, router: router, dataSource: dataSource)

    presenter.viewDidLoad()

    XCTAssertTrue(router.invokedShowError)
    XCTAssertEqual(router.invokedShowErrorParameters?.message, "Invalid json")
  }

  func testTrendingPresenter_fetchShowsFailure_andPresentError() {
    let error = TrendingError.parseError("Invalid json")
    let repository = ErrorTrendingRepositoryMock(error: error)
    let interactor = TrendingServiceMock(repository: repository, imageRepository: imageRepositoryMock)
    let presenter = TrendingiOSPresenter(view: view, interactor: interactor, router: router, dataSource: dataSource)

    presenter.currentTrendingType.value = .shows
    presenter.viewDidLoad()

    XCTAssertTrue(router.invokedShowError)
    XCTAssertEqual(router.invokedShowErrorParameters?.message, "Invalid json")
  }

  func testTrendingPresenter_fetchMoviesSuccess_andPresentMovies() {
    let movies = createMockMovies()
    let images = createImagesEntityMock()
    let repository = TrendingMoviesRepositoryMock(movies: movies)
    let interactor = TrendingServiceMock(repository: repository, imageRepository: createMovieImagesRepositoryMock(images))
    let presenter = TrendingiOSPresenter(view: view, interactor: interactor, router: router, dataSource: dataSource)

    presenter.viewDidLoad()

    let expectedViewModel = movies.map { trendingMovie -> TrendingViewModel in
      let type = trendingMovie.movie.ids.tmdbModelType()
      return TrendingViewModel(title: trendingMovie.movie.title ?? "TBA", type: type)
    }

    XCTAssertTrue(view.invokedShow)
    XCTAssertTrue(dataSource.invokedSetViewModels)
    XCTAssertEqual(dataSource.viewModels, expectedViewModel)
  }

  func testTrendingPresenter_fetchShowsSuccess_andPresentShows() {
    let images = createImagesEntityMock()
    let imagesRepository = createMovieImagesRepositoryMock(images)
    let interactor = TrendingServiceMock(repository: trendingRepositoryMock, imageRepository: imagesRepository)
    let presenter = TrendingiOSPresenter(view: view, interactor: interactor, router: router, dataSource: dataSource)

    presenter.currentTrendingType.value = .shows
    presenter.viewDidLoad()

    XCTAssertTrue(view.invokedShow)
  }

  func testTrendingPresenter_fetchMoviewSuccess_andPresentNoMovies() {
    let movies = [TrendingMovie]()
    let images = createImagesEntityMock()
    let repository = TrendingMoviesRepositoryMock(movies: movies)
    let interactor = TrendingServiceMock(repository: repository, imageRepository: createMovieImagesRepositoryMock(images))

    let presenter = TrendingiOSPresenter(view: view, interactor: interactor, router: router, dataSource: dataSource)

    presenter.viewDidLoad()

    XCTAssertTrue(view.invokedShowEmptyView)
    XCTAssertFalse(view.invokedShow)
  }

  func testTrendingPresenter_fetchMoviesFailure_andIsCustomError() {
    let userInfo = [NSLocalizedDescriptionKey: "Custom list movies error"]
    let error = NSError(domain: "com.arctouch.CouchTracker", code: 10, userInfo: userInfo)
    let interactor = TrendingServiceMock(repository: ErrorTrendingRepositoryMock(error: error), imageRepository: imageRepositoryMock)

    let presenter = TrendingiOSPresenter(view: view, interactor: interactor, router: router, dataSource: dataSource)

    presenter.viewDidLoad()

    XCTAssertTrue(router.invokedShowError)
    XCTAssertEqual(router.invokedShowErrorParameters?.message, "Custom list movies error")
  }

  func testTrendingPresenter_requestToShowDetailsOfMovie_notifyRouterToShowDetails() {
    let movieIndex = 1
    let movies = createMockMovies()
    let images =  createImagesEntityMock()
    let repository = TrendingMoviesRepositoryMock(movies: movies)
    let interactor = TrendingServiceMock(repository: repository, imageRepository: createMovieImagesRepositoryMock(images))
    let presenter = TrendingiOSPresenter(view: view, interactor: interactor, router: router, dataSource: dataSource)

    presenter.viewDidLoad()
    presenter.showDetailsOfTrending(at: movieIndex)
    
    let expectedMovie = MovieEntityMapper.entity(for: movies[movieIndex].movie)

    XCTAssertTrue(router.invokedMovieDetails)
    XCTAssertEqual(router.invokedMovieDetailsParameters?.movie, expectedMovie)
  }

  func testTrendingPresenter_requestToShowDetailsOfShow_notifyRouterToShowDetails() {
    let showIndex = 1
    let shows = createTrendingShowsMock()
    let images = createImagesEntityMock()
    let repository = TrendingShowsRepositoryMock(shows: shows)
    let interactor = TrendingServiceMock(repository: repository, imageRepository: createMovieImagesRepositoryMock(images))
    let presenter = TrendingiOSPresenter(view: view, interactor: interactor, router: router, dataSource: dataSource)

    presenter.currentTrendingType.value = .shows
    presenter.viewDidLoad()
    presenter.showDetailsOfTrending(at: 1)

    let expectedShow = ShowEntityMapper.entity(for: shows[showIndex].show)

    XCTAssertTrue(router.invokedShowDetails)
    XCTAssertEqual(router.invokedShowDetailsParameters?.show, expectedShow)
  }

  func testTrendingPresenter_requestToShowAppSettings_notifyRouter() {
    let repository = EmptyTrendingRepositoryMock()
    let interactor = TrendingServiceMock(repository: repository, imageRepository: imageRepositoryMock)
    let presenter = TrendingiOSPresenter(view: view, interactor: interactor, router: router, dataSource: dataSource)

    presenter.showAppSettings()

    XCTAssertTrue(router.invokedShowAppSettings)
  }

  func testTrendingPresenter_requestToShowSearchMovie_notifyRouter() {
    //Given
    let searchResultEntities = createSearchResultsMock()
    let searchView = SearchViewMock()
    let searchRepository = SearchStoreMock(results: searchResultEntities)
    let searchInteractor = SearchInteractorMock(repository: searchRepository)

    let view = TrendingViewMock()
    let repository = EmptyTrendingRepositoryMock()
    let interactor = TrendingServiceMock(repository: repository, imageRepository: imageRepositoryMock)
    let router = TrendingRouterMock()
    let dataSource = TrendingDataSourceMock()
    let presenter = TrendingiOSPresenter(view: view, interactor: interactor, router: router, dataSource: dataSource)
    let searchPresenter = SearchiOSPresenter(view: searchView, interactor: searchInteractor, resultOutput: presenter)

    //When
    searchPresenter.searchMovies(query: "Tron")
    presenter.showDetailsOfTrending(at: 0)

    //Then
    XCTAssertTrue(router.invokedMovieDetails)
  }
}
