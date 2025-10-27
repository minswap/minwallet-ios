// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetScriptUtxosQuery: GraphQLQuery {
  public static let operationName: String = "GetScriptUtxos"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetScriptUtxos($txIns: [String!]!) { getScriptUtxos(txIns: $txIns) { __typename rawDatum rawUtxo } }"#
    ))

  public var txIns: [String]

  public init(txIns: [String]) {
    self.txIns = txIns
  }

  public var __variables: Variables? { ["txIns": txIns] }

  public struct Data: MinWalletAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getScriptUtxos", [GetScriptUtxo]?.self, arguments: ["txIns": .variable("txIns")]),
    ] }

    public var getScriptUtxos: [GetScriptUtxo]? { __data["getScriptUtxos"] }

    /// GetScriptUtxo
    ///
    /// Parent Type: `ScriptUtxo`
    public struct GetScriptUtxo: MinWalletAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.ScriptUtxo }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("rawDatum", String.self),
        .field("rawUtxo", String.self),
      ] }

      public var rawDatum: String { __data["rawDatum"] }
      public var rawUtxo: String { __data["rawUtxo"] }
    }
  }
}
