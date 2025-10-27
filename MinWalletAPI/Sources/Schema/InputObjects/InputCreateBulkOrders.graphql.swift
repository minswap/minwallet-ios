// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputCreateBulkOrders: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    batcherFeeReductionOptions: GraphQLNullable<InputCommonBatcherFeeReductionOptions> = nil,
    orders: [InputCreateOrderOptions],
    publicKey: String,
    sender: String
  ) {
    __data = InputDict([
      "batcherFeeReductionOptions": batcherFeeReductionOptions,
      "orders": orders,
      "publicKey": publicKey,
      "sender": sender
    ])
  }

  public var batcherFeeReductionOptions: GraphQLNullable<InputCommonBatcherFeeReductionOptions> {
    get { __data["batcherFeeReductionOptions"] }
    set { __data["batcherFeeReductionOptions"] = newValue }
  }

  public var orders: [InputCreateOrderOptions] {
    get { __data["orders"] }
    set { __data["orders"] = newValue }
  }

  public var publicKey: String {
    get { __data["publicKey"] }
    set { __data["publicKey"] = newValue }
  }

  public var sender: String {
    get { __data["sender"] }
    set { __data["sender"] = newValue }
  }
}
