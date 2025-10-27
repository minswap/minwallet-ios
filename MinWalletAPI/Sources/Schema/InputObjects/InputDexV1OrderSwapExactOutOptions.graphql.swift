// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct InputDexV1OrderSwapExactOutOptions: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    assetIn: InputAsset,
    assetOutAmount: InputAssetAmount,
    maximumAmountIn: BigInt
  ) {
    __data = InputDict([
      "assetIn": assetIn,
      "assetOutAmount": assetOutAmount,
      "maximumAmountIn": maximumAmountIn
    ])
  }

  public var assetIn: InputAsset {
    get { __data["assetIn"] }
    set { __data["assetIn"] = newValue }
  }

  public var assetOutAmount: InputAssetAmount {
    get { __data["assetOutAmount"] }
    set { __data["assetOutAmount"] = newValue }
  }

  public var maximumAmountIn: BigInt {
    get { __data["maximumAmountIn"] }
    set { __data["maximumAmountIn"] = newValue }
  }
}
