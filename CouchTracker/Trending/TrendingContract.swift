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

import RxSwift
import Trakt_Swift

enum TrendingType {
  case movies
  case shows
}

protocol TrendingPresenter: class {
  init(view: TrendingView, interactor: TrendingInteractor, router: TrendingRouter)

  func fetchTrending(of type: TrendingType)

  func showDetailsOf(trending type: TrendingType, at index: Int)
}

protocol TrendingView: BaseView {
  var presenter: TrendingPresenter! { get set }
  var searchView: SearchView! { get set }

  func showEmptyView()
  func show(trending: [TrendingViewModel])
}

protocol TrendingRouter: class {
  func showDetails(of movie: TrendingMovieEntity)
  func showError(message: String)
}

protocol TrendingInteractor: class {
  init(repository: TrendingRepository, imageRepository: ImageRepository)

  func fetchMovies(page: Int, limit: Int) -> Observable<[TrendingMovieEntity]>
  func fetchShows(page: Int, limit: Int) -> Observable<[TrendingShowEntity]>
}

protocol TrendingRepository: class {
  func fetchMovies(page: Int, limit: Int) -> Observable<[TrendingMovie]>
  func fetchShows(page: Int, limit: Int) -> Observable<[TrendingShow]>
}