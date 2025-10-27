// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ADAHandleNameQuery: GraphQLQuery {
  public static let operationName: String = "ADAHandleNameQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ADAHandleNameQuery($address: String!) { getWalletAssetsPositions(address: $address) { __typename nfts { __typename asset { __typename currencySymbol tokenName } } } }"#
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
      .field("getWalletAssetsPositions", GetWalletAssetsPositions.self, arguments: ["address": .variable("address")]),
    ] }

    public var getWalletAssetsPositions: GetWalletAssetsPositions { __data["getWalletAssetsPositions"] }

    /// GetWalletAssetsPositions
    ///
    /// Parent Type: `WalletAssetsPositions`
    public struct GetWalletAssetsPositions: MinWalletAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.WalletAssetsPositions }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("nfts", [Nft].self),
      ] }

      public var nfts: [Nft] { __data["nfts"] }

      /// GetWalletAssetsPositions.Nft
      ///
      /// Parent Type: `PortfolioNFTPosition`
      public struct Nft: MinWalletAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.PortfolioNFTPosition }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("asset", Asset.self),
        ] }

        public var asset: Asset { __data["asset"] }

        /// GetWalletAssetsPositions.Nft.Asset
        ///
        /// Parent Type: `Asset`
        public struct Asset: MinWalletAPI.SelectionSet {
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
}
