// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputAssetAmount: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    amount: BigInt,
    asset: InputAsset
  ) {
    __data = InputDict([
      "amount": amount,
      "asset": asset
    ])
  }

  public var amount: BigInt {
    get { __data["amount"] }
    set { __data["amount"] = newValue }
  }

  public var asset: InputAsset {
    get { __data["asset"] }
    set { __data["asset"] = newValue }
  }
}
