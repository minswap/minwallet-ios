// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct TopAssetsSortInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    column: GraphQLEnum<TopAssetsSortColumn>,
    type: GraphQLEnum<SortType>
  ) {
    __data = InputDict([
      "column": column,
      "type": type
    ])
  }

  public var column: GraphQLEnum<TopAssetsSortColumn> {
    get { __data["column"] }
    set { __data["column"] = newValue }
  }

  public var type: GraphQLEnum<SortType> {
    get { __data["type"] }
    set { __data["type"] = newValue }
  }
}
