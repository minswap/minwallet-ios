// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputDexV2OrderSwapExactOutOptions: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    assetIn: InputAsset,
    direction: GraphQLEnum<OrderV2Direction>,
    expectedReceived: BigInt,
    lpAsset: InputAsset,
    maximumAmountIn: BigInt
  ) {
    __data = InputDict([
      "assetIn": assetIn,
      "direction": direction,
      "expectedReceived": expectedReceived,
      "lpAsset": lpAsset,
      "maximumAmountIn": maximumAmountIn
    ])
  }

  public var assetIn: InputAsset {
    get { __data["assetIn"] }
    set { __data["assetIn"] = newValue }
  }

  public var direction: GraphQLEnum<OrderV2Direction> {
    get { __data["direction"] }
    set { __data["direction"] = newValue }
  }

  public var expectedReceived: BigInt {
    get { __data["expectedReceived"] }
    set { __data["expectedReceived"] = newValue }
  }

  public var lpAsset: InputAsset {
    get { __data["lpAsset"] }
    set { __data["lpAsset"] = newValue }
  }

  public var maximumAmountIn: BigInt {
    get { __data["maximumAmountIn"] }
    set { __data["maximumAmountIn"] = newValue }
  }
}
