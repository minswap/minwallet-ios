// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FinalizeAndSubmitMutation: GraphQLMutation {
  public static let operationName: String = "FinalizeAndSubmit"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation FinalizeAndSubmit($input: InputFinalizeAndSubmit!) { finalizeAndSubmit(input: $input) }"#
    ))

  public var input: InputFinalizeAndSubmit

  public init(input: InputFinalizeAndSubmit) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: MinWalletAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { MinWalletAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("finalizeAndSubmit", String.self, arguments: ["input": .variable("input")]),
    ] }

    public var finalizeAndSubmit: String { __data["finalizeAndSubmit"] }
  }
}
