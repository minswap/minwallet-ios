// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputDexV2OrderSwapExactInOptions: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    assetInAmount: InputAssetAmount,
    assetOut: InputAsset,
    direction: GraphQLEnum<OrderV2Direction>,
    lpAsset: InputAsset,
    minimumAmountOut: BigInt
  ) {
    __data = InputDict([
      "assetInAmount": assetInAmount,
      "assetOut": assetOut,
      "direction": direction,
      "lpAsset": lpAsset,
      "minimumAmountOut": minimumAmountOut
    ])
  }

  public var assetInAmount: InputAssetAmount {
    get { __data["assetInAmount"] }
    set { __data["assetInAmount"] = newValue }
  }

  public var assetOut: InputAsset {
    get { __data["assetOut"] }
    set { __data["assetOut"] = newValue }
  }

  public var direction: GraphQLEnum<OrderV2Direction> {
    get { __data["direction"] }
    set { __data["direction"] = newValue }
  }

  public var lpAsset: InputAsset {
    get { __data["lpAsset"] }
    set { __data["lpAsset"] = newValue }
  }

  public var minimumAmountOut: BigInt {
    get { __data["minimumAmountOut"] }
    set { __data["minimumAmountOut"] = newValue }
  }
}
