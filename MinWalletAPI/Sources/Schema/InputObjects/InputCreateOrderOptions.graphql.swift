// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputCreateOrderOptions: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    dexV1OrderSwapExactIn: GraphQLNullable<InputDexV1OrderSwapExactInOptions> = nil,
    dexV1OrderSwapExactOut: GraphQLNullable<InputDexV1OrderSwapExactOutOptions> = nil,
    dexV2OrderMultiRouting: GraphQLNullable<InputDexV2OrderMultiRoutingOptions> = nil,
    dexV2OrderSwapExactIn: GraphQLNullable<InputDexV2OrderSwapExactInOptions> = nil,
    dexV2OrderSwapExactOut: GraphQLNullable<InputDexV2OrderSwapExactOutOptions> = nil,
    stableswapOrder: GraphQLNullable<InputStableswapOrderOptions> = nil
  ) {
    __data = InputDict([
      "dexV1OrderSwapExactIn": dexV1OrderSwapExactIn,
      "dexV1OrderSwapExactOut": dexV1OrderSwapExactOut,
      "dexV2OrderMultiRouting": dexV2OrderMultiRouting,
      "dexV2OrderSwapExactIn": dexV2OrderSwapExactIn,
      "dexV2OrderSwapExactOut": dexV2OrderSwapExactOut,
      "stableswapOrder": stableswapOrder
    ])
  }

  public var dexV1OrderSwapExactIn: GraphQLNullable<InputDexV1OrderSwapExactInOptions> {
    get { __data["dexV1OrderSwapExactIn"] }
    set { __data["dexV1OrderSwapExactIn"] = newValue }
  }

  public var dexV1OrderSwapExactOut: GraphQLNullable<InputDexV1OrderSwapExactOutOptions> {
    get { __data["dexV1OrderSwapExactOut"] }
    set { __data["dexV1OrderSwapExactOut"] = newValue }
  }

  public var dexV2OrderMultiRouting: GraphQLNullable<InputDexV2OrderMultiRoutingOptions> {
    get { __data["dexV2OrderMultiRouting"] }
    set { __data["dexV2OrderMultiRouting"] = newValue }
  }

  public var dexV2OrderSwapExactIn: GraphQLNullable<InputDexV2OrderSwapExactInOptions> {
    get { __data["dexV2OrderSwapExactIn"] }
    set { __data["dexV2OrderSwapExactIn"] = newValue }
  }

  public var dexV2OrderSwapExactOut: GraphQLNullable<InputDexV2OrderSwapExactOutOptions> {
    get { __data["dexV2OrderSwapExactOut"] }
    set { __data["dexV2OrderSwapExactOut"] = newValue }
  }

  public var stableswapOrder: GraphQLNullable<InputStableswapOrderOptions> {
    get { __data["stableswapOrder"] }
    set { __data["stableswapOrder"] = newValue }
  }
}
