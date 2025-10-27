// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputStableswapOrderOptions: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    assetInAmount: InputAssetAmount,
    assetInIndex: BigInt,
    assetOutIndex: BigInt,
    lpAsset: InputAsset,
    minimumAssetOut: BigInt
  ) {
    __data = InputDict([
      "assetInAmount": assetInAmount,
      "assetInIndex": assetInIndex,
      "assetOutIndex": assetOutIndex,
      "lpAsset": lpAsset,
      "minimumAssetOut": minimumAssetOut
    ])
  }

  public var assetInAmount: InputAssetAmount {
    get { __data["assetInAmount"] }
    set { __data["assetInAmount"] = newValue }
  }

  public var assetInIndex: BigInt {
    get { __data["assetInIndex"] }
    set { __data["assetInIndex"] = newValue }
  }

  public var assetOutIndex: BigInt {
    get { __data["assetOutIndex"] }
    set { __data["assetOutIndex"] = newValue }
  }

  public var lpAsset: InputAsset {
    get { __data["lpAsset"] }
    set { __data["lpAsset"] = newValue }
  }

  public var minimumAssetOut: BigInt {
    get { __data["minimumAssetOut"] }
    set { __data["minimumAssetOut"] = newValue }
  }
}
