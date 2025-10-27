// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputFinalizeAndSubmit: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    tx: String,
    witnessSet: String
  ) {
    __data = InputDict([
      "tx": tx,
      "witnessSet": witnessSet
    ])
  }

  public var tx: String {
    get { __data["tx"] }
    set { __data["tx"] = newValue }
  }

  public var witnessSet: String {
    get { __data["witnessSet"] }
    set { __data["witnessSet"] = newValue }
  }
}
