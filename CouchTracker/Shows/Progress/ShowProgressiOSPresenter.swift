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

final class ShowsProgressiOSPresenter: ShowsProgressPresenter {
  private weak var view: ShowsProgressView?
  private let interactor: ShowsProgressInteractor
  private let disposeBag = DisposeBag()
  private var entities = [WatchedShowEntity]()

  init(view: ShowsProgressView, interactor: ShowsProgressInteractor) {
    self.view = view
    self.interactor = interactor
  }

  func viewDidLoad() {
    interactor.fetchWatchedShowsProgress()
      .do(onNext: { [unowned self] in self.entities.append($0) })
      .map { [unowned self] in self.mapToViewModel($0) }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] in
        self.view?.showNew(viewModel: $0)
      }, onError: {
        print($0)
      }, onCompleted: { [unowned self] in
        self.view?.updateFinished()
      }).disposed(by: disposeBag)
  }

  private func mapToViewModel(_ entity: WatchedShowEntity) -> WatchedShowViewModel {
    let nextEpisodeTitle = entity.nextEpisode.map { "\($0.season)x\($0.number) \($0.title)" }
    let nextEpisodeDate = entity.nextEpisode?.firstAired?.shortString()
    let showStatus = entity.show.status?.rawValue.localized

    let status = (nextEpisodeDate ?? showStatus) ?? "Unknown".localized

    let x = String(entity.aired - entity.completed)
    let episodesRemaining = "episodes remaining".localized(x)

    return WatchedShowViewModel(title: entity.show.title ?? "TBA".localized,
                                 nextEpisode: nextEpisodeTitle,
                                 networkInfo: entity.show.network ?? "Unknown",
                                 episodesRemaining: episodesRemaining,
                                 status: status,
                                 tmdbId: entity.show.ids.tmdb)
  }
}