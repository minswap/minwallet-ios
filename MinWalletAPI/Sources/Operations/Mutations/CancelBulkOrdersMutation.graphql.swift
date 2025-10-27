// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CancelBulkOrdersMutation: GraphQLMutation {
  public static let operationName: String = "CancelBulkOrdersMutation"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CancelBulkOrdersMutation($input: InputCancelBulkOrders!) { cancelBulkOrders(input: $input) }"#
    ))

  public var input: InputCancelBulkOrders

  public init(input: InputCancelBulkOrders) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: MinWalletAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("cancelBulkOrders", String.self, arguments: ["input": .variable("input")]),
    ] }

    public var cancelBulkOrders: String { __data["cancelBulkOrders"] }
  }
}
