// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RiskScoreOfAssetQuery: GraphQLQuery {
  public static let operationName: String = "RiskScoreOfAssetQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query RiskScoreOfAssetQuery($asset: InputAsset!) { riskScoreOfAsset(asset: $asset) { __typename assetName riskCategory } }"#
    ))

  public var asset: InputAsset

  public init(asset: InputAsset) {
    self.asset = asset
  }

  public var __variables: Variables? { ["asset": asset] }

  public struct Data: MinWalletAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("riskScoreOfAsset", RiskScoreOfAsset?.self, arguments: ["asset": .variable("asset")]),
    ] }

    public var riskScoreOfAsset: RiskScoreOfAsset? { __data["riskScoreOfAsset"] }

    /// RiskScoreOfAsset
    ///
    /// Parent Type: `RiskScore`
    public struct RiskScoreOfAsset: MinWalletAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.RiskScore }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("assetName", String.self),
        .field("riskCategory", GraphQLEnum<MinWalletAPI.RiskCategory>.self),
      ] }

      public var assetName: String { __data["assetName"] }
      public var riskCategory: GraphQLEnum<MinWalletAPI.RiskCategory> { __data["riskCategory"] }
    }
  }
}
