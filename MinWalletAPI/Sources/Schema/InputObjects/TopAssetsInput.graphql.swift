// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct TopAssetsInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    favoriteAssets: GraphQLNullable<[InputAsset]> = nil,
    limit: GraphQLNullable<Int> = nil,
    onlyVerified: GraphQLNullable<Bool> = nil,
    searchAfter: GraphQLNullable<[String]> = nil,
    sortBy: GraphQLNullable<TopAssetsSortInput> = nil,
    term: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "favoriteAssets": favoriteAssets,
      "limit": limit,
      "onlyVerified": onlyVerified,
      "searchAfter": searchAfter,
      "sortBy": sortBy,
      "term": term
    ])
  }

  public var favoriteAssets: GraphQLNullable<[InputAsset]> {
    get { __data["favoriteAssets"] }
    set { __data["favoriteAssets"] = newValue }
  }

  public var limit: GraphQLNullable<Int> {
    get { __data["limit"] }
    set { __data["limit"] = newValue }
  }

  public var onlyVerified: GraphQLNullable<Bool> {
    get { __data["onlyVerified"] }
    set { __data["onlyVerified"] = newValue }
  }

  public var searchAfter: GraphQLNullable<[String]> {
    get { __data["searchAfter"] }
    set { __data["searchAfter"] = newValue }
  }

  public var sortBy: GraphQLNullable<TopAssetsSortInput> {
    get { __data["sortBy"] }
    set { __data["sortBy"] = newValue }
  }

  public var term: GraphQLNullable<String> {
    get { __data["term"] }
    set { __data["term"] = newValue }
  }
}
