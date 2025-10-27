// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputCommonBatcherFeeReductionOptions: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    userAddress: String,
    userReferences: [String],
    userUtxos: [String]
  ) {
    __data = InputDict([
      "userAddress": userAddress,
      "userReferences": userReferences,
      "userUtxos": userUtxos
    ])
  }

  public var userAddress: String {
    get { __data["userAddress"] }
    set { __data["userAddress"] = newValue }
  }

  public var userReferences: [String] {
    get { __data["userReferences"] }
    set { __data["userReferences"] = newValue }
  }

  public var userUtxos: [String] {
    get { __data["userUtxos"] }
    set { __data["userUtxos"] = newValue }
  }
}
