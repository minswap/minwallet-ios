// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct IosTradeEstimateInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    amount: BigInt,
    inputAsset: InputAsset,
    isApplied: Bool,
    isSwapExactIn: Bool,
    outputAsset: InputAsset
  ) {
    __data = InputDict([
      "amount": amount,
      "inputAsset": inputAsset,
      "isApplied": isApplied,
      "isSwapExactIn": isSwapExactIn,
      "outputAsset": outputAsset
    ])
  }

  public var amount: BigInt {
    get { __data["amount"] }
    set { __data["amount"] = newValue }
  }

  public var inputAsset: InputAsset {
    get { __data["inputAsset"] }
    set { __data["inputAsset"] = newValue }
  }

  public var isApplied: Bool {
    get { __data["isApplied"] }
    set { __data["isApplied"] = newValue }
  }

  public var isSwapExactIn: Bool {
    get { __data["isSwapExactIn"] }
    set { __data["isSwapExactIn"] = newValue }
  }

  public var outputAsset: InputAsset {
    get { __data["outputAsset"] }
    set { __data["outputAsset"] = newValue }
  }
}
