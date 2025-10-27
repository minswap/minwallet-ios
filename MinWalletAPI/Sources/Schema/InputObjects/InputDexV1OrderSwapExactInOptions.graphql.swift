// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputDexV1OrderSwapExactInOptions: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    assetInAmount: InputAssetAmount,
    assetOut: InputAsset,
    minimumAmountOut: BigInt
  ) {
    __data = InputDict([
      "assetInAmount": assetInAmount,
      "assetOut": assetOut,
      "minimumAmountOut": minimumAmountOut
    ])
  }

  public var assetInAmount: InputAssetAmount {
    get { __data["assetInAmount"] }
    set { __data["assetInAmount"] = newValue }
  }

  public var assetOut: InputAsset {
    get { __data["assetOut"] }
    set { __data["assetOut"] = newValue }
  }

  public var minimumAmountOut: BigInt {
    get { __data["minimumAmountOut"] }
    set { __data["minimumAmountOut"] = newValue }
  }
}
