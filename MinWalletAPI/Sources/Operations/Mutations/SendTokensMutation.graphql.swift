// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SendTokensMutation: GraphQLMutation {
  public static let operationName: String = "SendTokens"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation SendTokens($input: InputSendTokens!) { sendTokens(input: $input) }"#
    ))

  public var input: InputSendTokens

  public init(input: InputSendTokens) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: MinWalletAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("sendTokens", String.self, arguments: ["input": .variable("input")]),
    ] }

    public var sendTokens: String { __data["sendTokens"] }
  }
}
