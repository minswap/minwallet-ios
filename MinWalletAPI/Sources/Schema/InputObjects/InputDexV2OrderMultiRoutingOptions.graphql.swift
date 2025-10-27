// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputDexV2OrderMultiRoutingOptions: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    assetIn: InputAssetAmount,
    lpAsset: InputAsset,
    minimumReceived: BigInt,
    routings: [InputOrderV2SwapRouting]
  ) {
    __data = InputDict([
      "assetIn": assetIn,
      "lpAsset": lpAsset,
      "minimumReceived": minimumReceived,
      "routings": routings
    ])
  }

  public var assetIn: InputAssetAmount {
    get { __data["assetIn"] }
    set { __data["assetIn"] = newValue }
  }

  public var lpAsset: InputAsset {
    get { __data["lpAsset"] }
    set { __data["lpAsset"] = newValue }
  }

  public var minimumReceived: BigInt {
    get { __data["minimumReceived"] }
    set { __data["minimumReceived"] = newValue }
  }

  public var routings: [InputOrderV2SwapRouting] {
    get { __data["routings"] }
    set { __data["routings"] = newValue }
  }
}
