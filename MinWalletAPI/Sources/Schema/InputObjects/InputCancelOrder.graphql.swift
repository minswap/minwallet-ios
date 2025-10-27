// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputCancelOrder: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    rawDatum: GraphQLNullable<String> = nil,
    utxo: String
  ) {
    __data = InputDict([
      "rawDatum": rawDatum,
      "utxo": utxo
    ])
  }

  public var rawDatum: GraphQLNullable<String> {
    get { __data["rawDatum"] }
    set { __data["rawDatum"] = newValue }
  }

  public var utxo: String {
    get { __data["utxo"] }
    set { __data["utxo"] = newValue }
  }
}
