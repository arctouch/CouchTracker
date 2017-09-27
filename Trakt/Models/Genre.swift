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

import ObjectMapper

public final class Genre: ImmutableMappable, Hashable {
  public let name: String
  public let slug: String

  public init(name: String, slug: String) {
    self.name = name
    self.slug = slug
  }

  public init(map: Map) throws {
    self.name = try map.value("name")
    self.slug = try map.value("slug")
  }

  public var hashValue: Int {
    return name.hashValue ^ slug.hashValue
  }

  public static func == (lhs: Genre, rhs: Genre) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}
