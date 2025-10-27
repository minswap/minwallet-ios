// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class NotificationGenerateAuthHashMutation: GraphQLMutation {
  public static let operationName: String = "NotificationGenerateAuthHash"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation NotificationGenerateAuthHash($identifier: String!) { notificationGenerateAuthHash(identifier: $identifier) }"#
    ))

  public var identifier: String

  public init(identifier: String) {
    self.identifier = identifier
  }

  public var __variables: Variables? { ["identifier": identifier] }

  public struct Data: MinWalletAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("notificationGenerateAuthHash", String.self, arguments: ["identifier": .variable("identifier")]),
    ] }

    public var notificationGenerateAuthHash: String { __data["notificationGenerateAuthHash"] }
  }
}
