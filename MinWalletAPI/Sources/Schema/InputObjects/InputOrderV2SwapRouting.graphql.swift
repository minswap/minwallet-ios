// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputOrderV2SwapRouting: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    direction: GraphQLEnum<OrderV2Direction>,
    lpAsset: InputAsset
  ) {
    __data = InputDict([
      "direction": direction,
      "lpAsset": lpAsset
    ])
  }

  public var direction: GraphQLEnum<OrderV2Direction> {
    get { __data["direction"] }
    set { __data["direction"] = newValue }
  }

  public var lpAsset: InputAsset {
    get { __data["lpAsset"] }
    set { __data["lpAsset"] = newValue }
  }
}
