// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TopAssetsQuery: GraphQLQuery {
  public static let operationName: String = "TopAssetsQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query TopAssetsQuery($input: TopAssetsInput) { topAssets(input: $input) { __typename searchAfter topAssets { __typename price asset { __typename currencySymbol metadata { __typename isVerified decimals ticker name description } tokenName details { __typename categories project socialLinks { __typename coinGecko coinMarketCap discord telegram twitter website } } } priceChange24h } } }"#
    ))

  public var input: GraphQLNullable<TopAssetsInput>

  public init(input: GraphQLNullable<TopAssetsInput>) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: MinWalletAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("topAssets", TopAssets.self, arguments: ["input": .variable("input")]),
    ] }

    public var topAssets: TopAssets { __data["topAssets"] }

    /// TopAssets
    ///
    /// Parent Type: `TopAssetsResponse`
    public struct TopAssets: MinWalletAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.TopAssetsResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("searchAfter", [String]?.self),
        .field("topAssets", [TopAsset].self),
      ] }

      public var searchAfter: [String]? { __data["searchAfter"] }
      public var topAssets: [TopAsset] { __data["topAssets"] }

      /// TopAssets.TopAsset
      ///
      /// Parent Type: `TopAsset`
      public struct TopAsset: MinWalletAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.TopAsset }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("price", MinWalletAPI.BigNumber.self),
          .field("asset", Asset.self),
          .field("priceChange24h", MinWalletAPI.BigNumber.self),
        ] }

        public var price: MinWalletAPI.BigNumber { __data["price"] }
        public var asset: Asset { __data["asset"] }
        public var priceChange24h: MinWalletAPI.BigNumber { __data["priceChange24h"] }

        /// TopAssets.TopAsset.Asset
        ///
        /// Parent Type: `Asset`
        public struct Asset: MinWalletAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Asset }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("currencySymbol", String.self),
            .field("metadata", Metadata?.self),
            .field("tokenName", String.self),
            .field("details", Details?.self),
          ] }

          public var currencySymbol: String { __data["currencySymbol"] }
          public var metadata: Metadata? { __data["metadata"] }
          public var tokenName: String { __data["tokenName"] }
          public var details: Details? { __data["details"] }

          /// TopAssets.TopAsset.Asset.Metadata
          ///
          /// Parent Type: `AssetMetadata`
          public struct Metadata: MinWalletAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.AssetMetadata }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("isVerified", Bool.self),
              .field("decimals", Int?.self),
              .field("ticker", String?.self),
              .field("name", String?.self),
              .field("description", String?.self),
            ] }

            public var isVerified: Bool { __data["isVerified"] }
            public var decimals: Int? { __data["decimals"] }
            public var ticker: String? { __data["ticker"] }
            public var name: String? { __data["name"] }
            public var description: String? { __data["description"] }
          }

          /// TopAssets.TopAsset.Asset.Details
          ///
          /// Parent Type: `AssetDetails`
          public struct Details: MinWalletAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.AssetDetails }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("categories", [String].self),
              .field("project", String.self),
              .field("socialLinks", SocialLinks?.self),
            ] }

            public var categories: [String] { __data["categories"] }
            public var project: String { __data["project"] }
            public var socialLinks: SocialLinks? { __data["socialLinks"] }

            /// TopAssets.TopAsset.Asset.Details.SocialLinks
            ///
            /// Parent Type: `AssetSocialLinks`
            public struct SocialLinks: MinWalletAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.AssetSocialLinks }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("coinGecko", String?.self),
                .field("coinMarketCap", String?.self),
                .field("discord", String?.self),
                .field("telegram", String?.self),
                .field("twitter", String?.self),
                .field("website", String?.self),
              ] }

              public var coinGecko: String? { __data["coinGecko"] }
              public var coinMarketCap: String? { __data["coinMarketCap"] }
              public var discord: String? { __data["discord"] }
              public var telegram: String? { __data["telegram"] }
              public var twitter: String? { __data["twitter"] }
              public var website: String? { __data["website"] }
            }
          }
        }
      }
    }
  }
}
