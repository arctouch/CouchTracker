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
import Moya
import Moya_ObjectMapper
import Trakt_Swift

final class APISearchRepository: SearchRepository {

  private let provider: RxMoyaProvider<Search>

  init(traktProvider: TraktProvider) {
    self.provider = traktProvider.search
  }

  func search(query: String, types: [SearchType], page: Int, limit: Int) -> Observable<[SearchResult]> {
    let target = Search.textQuery(types: types, query: query, page: page, limit: limit)

    let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)

    return provider.request(target)
      .subscribeOn(scheduler)
      .observeOn(scheduler)
      .mapArray(SearchResult.self)
  }
}