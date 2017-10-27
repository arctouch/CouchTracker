import Trakt
import TMDBSwift
import TVDBSwift
import Carlos
import Moya

final class Environment {
  static let instance = Environment()
  let trakt: TraktProvider
  let tmdb: TMDBProvider
  let tvdb: TVDBProvider
  let loginObservable: TraktLoginObservable
  let defaultOutput: TraktLoginOutput
  let diskCache: AnyCache<Int, NSData>
  let memoryCache: AnyCache<Int, NSData>

  private init() {
    let trakt = Trakt(clientId: Secrets.Trakt.clientId,
                       clientSecret: Secrets.Trakt.clientSecret,
                       redirectURL: Secrets.Trakt.redirectURL)
    self.tmdb = TMDB(apiKey: Secrets.TMDB.apiKey)
    self.tvdb = TVDB(apiKey: Secrets.TVDB.apiKey)

//    trakt.addPlugin(NetworkLoggerPlugin(verbose: true, cURL: false))

    self.trakt = trakt

    let traktLoginStore = TraktLoginStore(trakt: trakt)

    self.loginObservable = traktLoginStore
    self.defaultOutput = traktLoginStore.loginOutput

    let carlosMemoryCache = MemoryCacheLevel<Int, NSData>()
    let carlosDiskCache = carlosMemoryCache.compose(DiskCacheLevel())

    self.memoryCache = AnyCache(CarlosCache(basicCache: carlosMemoryCache.normalize()))
    self.diskCache = AnyCache(CarlosCache(basicCache: carlosDiskCache))
  }
}
