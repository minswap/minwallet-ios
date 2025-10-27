// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputAsset: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    currencySymbol: String,
    tokenName: String
  ) {
    __data = InputDict([
      "currencySymbol": currencySymbol,
      "tokenName": tokenName
    ])
  }

  public var currencySymbol: String {
    get { __data["currencySymbol"] }
    set { __data["currencySymbol"] = newValue }
  }

  public var tokenName: String {
    get { __data["tokenName"] }
    set { __data["tokenName"] = newValue }
  }
}
