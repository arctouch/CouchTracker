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

import UIKit
import Trakt_Swift

final class TrendingiOSRouter: TrendingRouter {

  private weak var viewController: UIViewController?
  private let traktProvider: TraktProvider
  private let tmdbProvider: TMDBProvider

  init(viewController: UIViewController, traktProvider: TraktProvider, tmdbProvider: TMDBProvider) {
    self.viewController = viewController
    self.traktProvider = traktProvider
    self.tmdbProvider = tmdbProvider
  }

  func showDetails(of movie: TrendingMovieEntity) {
    guard let navigationController = viewController?.navigationController else { return }

    let movieIds = movie.movie.ids
    let view = MovieDetailsModule.setupModule(traktProvider: traktProvider,
                                              tmdbProvider: tmdbProvider, movieIds: movieIds)

    guard let viewController = view as? UIViewController else {
      fatalError("view should be an instance of UIViewController")
    }

    navigationController.pushViewController(viewController, animated: true)
  }

  func showError(message: String) {
    guard let viewController = viewController else { return }

    let errorAlert = UIAlertController.createErrorAlert(message: message)
    viewController.present(errorAlert, animated: true)
  }
}