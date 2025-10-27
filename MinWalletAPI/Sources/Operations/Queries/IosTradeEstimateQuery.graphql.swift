// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class IosTradeEstimateQuery: GraphQLQuery {
  public static let operationName: String = "IosTradeEstimateQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query IosTradeEstimateQuery($input: IosTradeEstimateInput!) { iosTradeEstimate(input: $input) { __typename estimateAmount inputIndex lpAssets { __typename currencySymbol tokenName } lpFee outputIndex path { __typename currencySymbol tokenName } priceImpact type direction } }"#
    ))

  public var input: IosTradeEstimateInput

  public init(input: IosTradeEstimateInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: MinWalletAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("iosTradeEstimate", IosTradeEstimate?.self, arguments: ["input": .variable("input")]),
    ] }

    public var iosTradeEstimate: IosTradeEstimate? { __data["iosTradeEstimate"] }

    /// IosTradeEstimate
    ///
    /// Parent Type: `IosTradeEstimateOutput`
    public struct IosTradeEstimate: MinWalletAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.IosTradeEstimateOutput }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("estimateAmount", MinWalletAPI.BigInt?.self),
        .field("inputIndex", Int?.self),
        .field("lpAssets", [LpAsset].self),
        .field("lpFee", MinWalletAPI.BigInt?.self),
        .field("outputIndex", Int?.self),
        .field("path", [Path].self),
        .field("priceImpact", Double?.self),
        .field("type", GraphQLEnum<MinWalletAPI.AMMType>.self),
        .field("direction", GraphQLEnum<MinWalletAPI.OrderV2Direction>?.self),
      ] }

      public var estimateAmount: MinWalletAPI.BigInt? { __data["estimateAmount"] }
      public var inputIndex: Int? { __data["inputIndex"] }
      public var lpAssets: [LpAsset] { __data["lpAssets"] }
      public var lpFee: MinWalletAPI.BigInt? { __data["lpFee"] }
      public var outputIndex: Int? { __data["outputIndex"] }
      public var path: [Path] { __data["path"] }
      public var priceImpact: Double? { __data["priceImpact"] }
      public var type: GraphQLEnum<MinWalletAPI.AMMType> { __data["type"] }
      public var direction: GraphQLEnum<MinWalletAPI.OrderV2Direction>? { __data["direction"] }

      /// IosTradeEstimate.LpAsset
      ///
      /// Parent Type: `Asset`
      public struct LpAsset: MinWalletAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Asset }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("currencySymbol", String.self),
          .field("tokenName", String.self),
        ] }

        public var currencySymbol: String { __data["currencySymbol"] }
        public var tokenName: String { __data["tokenName"] }
      }

      /// IosTradeEstimate.Path
      ///
      /// Parent Type: `Asset`
      public struct Path: MinWalletAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Asset }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("currencySymbol", String.self),
          .field("tokenName", String.self),
        ] }

        public var currencySymbol: String { __data["currencySymbol"] }
        public var tokenName: String { __data["tokenName"] }
      }
    }
  }
}
