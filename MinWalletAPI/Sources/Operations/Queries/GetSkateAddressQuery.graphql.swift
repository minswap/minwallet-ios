// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetSkateAddressQuery: GraphQLQuery {
  public static let operationName: String = "GetSkateAddressQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetSkateAddressQuery($address: String!) { getStakeAddress(address: $address) }"#
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
      .field("getStakeAddress", String.self, arguments: ["address": .variable("address")]),
    ] }

    public var getStakeAddress: String { __data["getStakeAddress"] }
  }
}
