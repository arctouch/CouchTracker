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

import TraktSwift

enum TokenResult: Hashable {
  case logged(token: Token, user: String)
  case error(error: TokenError)

  var hashValue: Int {
    switch self {
    case .logged(let token, let user):
      return token.hashValue ^ user.hashValue
    case .error(let error):
      return error.hashValue
    }
  }

  static func == (lhs: TokenResult, rhs: TokenResult) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}