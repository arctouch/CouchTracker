import TraktSwift
import RxSwift
import Moya

final class ShowsProgressAPIRepository: ShowsProgressRepository {
  private let trakt: TraktProvider
  private let dataSource: ShowsProgressDataSource
  private let schedulers: Schedulers
  private let disposeBag = DisposeBag()

  init(trakt: TraktProvider, dataSource: ShowsProgressDataSource, schedulers: Schedulers) {
    self.trakt = trakt
    self.dataSource = dataSource
    self.schedulers = schedulers
  }

  func fetchWatchedShows(extended: Extended) -> Observable<[WatchedShowEntity]> {
    fetchWatchedShowsFromAPI(extended: extended)
      .observeOn(schedulers.dataSourceScheduler)
      .do(onNext: { [unowned self] entities in
        try self.dataSource.addWatched(shows: entities)
      })
      .subscribe()
      .disposed(by: disposeBag)

    return fetchWatchedShowsFromDataSource().subscribeOn(schedulers.dataSourceScheduler)
  }

  private func fetchWatchedShowsFromAPI(extended: Extended) -> Observable<[WatchedShowEntity]> {
    let api = trakt.sync.rx.request(Sync.watched(type: .shows, extended: extended)).map([BaseShow].self).asObservable()

    return api.observeOn(schedulers.networkScheduler)
      .flatMap { Observable.from($0) }
      .flatMap { [unowned self] in self.fetchShowProgress($0) }
      .toArray()
  }

  private func fetchWatchedShowsFromDataSource() -> Observable<[WatchedShowEntity]> {
    return dataSource.fetchWatchedShows()
  }

  private func fetchShowProgress(_ baseShow: BaseShow) -> Observable<WatchedShowEntity> {
    guard let show = baseShow.show else { return Observable.empty() }

    return fetchShowProgress(ids: show.ids)
      .flatMap { [unowned self] in return self.mapToEntity(baseShow, builder: $0) }
  }

  private func fetchShowProgress(ids: ShowIds) -> Observable<WatchedShowBuilder> {
    let builder = WatchedShowBuilder(ids: ids)

    return buildProgressForShow(builder)
      .flatMap { [unowned self] in self.fetchNextEpisodeDetails($0) }
  }

  private func buildProgressForShow(_ builder: WatchedShowBuilder) -> Observable<WatchedShowBuilder> {
    let showId = builder.ids.realId

    let observable = fetchShowProgress(showId: showId)

    return observable.map {
      builder.detailShow = $0
      return builder
    }
  }

  private func fetchShowProgress(showId: String) -> Observable<BaseShow> {
    let target = Shows.watchedProgress(showId: showId, hidden: true, specials: true, countSpecials: true)

    return trakt.shows.rx.request(target).map(BaseShow.self).asObservable().observeOn(schedulers.networkScheduler)
  }

  private func fetchNextEpisodeDetails(_ builder: WatchedShowBuilder) -> Observable<WatchedShowBuilder> {
    guard let episode = builder.detailShow?.nextEpisode else { return Observable.just(builder) }

    let showId = builder.ids.realId

    let observable = fetchDetailsOf(episodeNumber: episode.number,
                                               on: episode.season, of: showId, extended: .full)

    return observable.map {
      builder.episode = $0
      return builder
      }.catchErrorJustReturn(builder)
  }

  private func fetchDetailsOf(episodeNumber: Int, on seasonNumber: Int,
                              of showId: String, extended: Extended) -> Observable<Episode> {
    let target = Episodes.summary(showId: showId, season: seasonNumber, episode: episodeNumber, extended: extended)

    return trakt.episodes.rx.request(target).map(Episode.self).asObservable().observeOn(schedulers.networkScheduler)
  }

  private func mapToEntity(_ baseShow: BaseShow, builder: WatchedShowBuilder) -> Observable<WatchedShowEntity> {
    guard let show = baseShow.show else { return Observable.empty() }

    let showIds = builder.ids

    let showEntity = ShowEntityMapper.entity(for: show)
    let episodeEntity = builder.episode.map { EpisodeEntityMapper.entity(for: $0, showIds: showIds) }

    let aired = builder.detailShow?.aired ?? 0
    let completed = builder.detailShow?.completed ?? 0

    let lastWatched = builder.detailShow?.lastWatchedAt

    let entity = WatchedShowEntity(show: showEntity,
                                   aired: aired,
                                   completed: completed,
                                   nextEpisode: episodeEntity,
                                   lastWatched: lastWatched)

    return Observable.just(entity).observeOn(schedulers.networkScheduler)
  }
}
