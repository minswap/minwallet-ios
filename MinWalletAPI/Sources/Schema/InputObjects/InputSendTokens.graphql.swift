// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputSendTokens: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    assetAmounts: [InputAssetAmount],
    publicKey: String,
    receiver: String,
    sendAll: GraphQLNullable<Bool> = nil,
    sender: String
  ) {
    __data = InputDict([
      "assetAmounts": assetAmounts,
      "publicKey": publicKey,
      "receiver": receiver,
      "sendAll": sendAll,
      "sender": sender
    ])
  }

  public var assetAmounts: [InputAssetAmount] {
    get { __data["assetAmounts"] }
    set { __data["assetAmounts"] = newValue }
  }

  public var publicKey: String {
    get { __data["publicKey"] }
    set { __data["publicKey"] = newValue }
  }

  public var receiver: String {
    get { __data["receiver"] }
    set { __data["receiver"] = newValue }
  }

  public var sendAll: GraphQLNullable<Bool> {
    get { __data["sendAll"] }
    set { __data["sendAll"] = newValue }
  }

  public var sender: String {
    get { __data["sender"] }
    set { __data["sender"] = newValue }
  }
}
