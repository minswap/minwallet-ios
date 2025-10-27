// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateBulkOrdersMutation: GraphQLMutation {
  public static let operationName: String = "CreateBulkOrders"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateBulkOrders($input: InputCreateBulkOrders!) { createBulkOrders(input: $input) }"#
    ))

  public var input: InputCreateBulkOrders

  public init(input: InputCreateBulkOrders) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: MinWalletAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createBulkOrders", String.self, arguments: ["input": .variable("input")]),
    ] }

    public var createBulkOrders: String { __data["createBulkOrders"] }
  }
}
