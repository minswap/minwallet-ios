// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetMinimumLovelaceQuery: GraphQLQuery {
  public static let operationName: String = "GetMinimumLovelaceQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetMinimumLovelaceQuery($address: String!) { getMinimumLovelace(address: $address) }"#
    ))

  public var address: String

  public init(address: String) {
    self.address = address
  }

  public var __variables: Variables? { ["address": address] }

  public struct Data: MinWalletAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getMinimumLovelace", MinWalletAPI.BigInt.self, arguments: ["address": .variable("address")]),
    ] }

    public var getMinimumLovelace: MinWalletAPI.BigInt { __data["getMinimumLovelace"] }
  }
}
