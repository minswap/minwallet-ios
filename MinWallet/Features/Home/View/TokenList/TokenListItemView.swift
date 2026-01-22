import SwiftUI
import SkeletonUI


struct TokenListItemView: View {
    @EnvironmentObject
    private var appSetting: AppSetting
    
    let token: TokenProtocol?
    let showSubPrice: Bool
    let showBottomLine: Bool
    
    @Binding var isFav: Bool
    
    init(
        token: TokenProtocol?,
        showSubPrice: Bool = false,
        showBottomLine: Bool = true,
        isFav: Bool = false
    ) {
        self.token = token
        self.showSubPrice = showSubPrice
        self.showBottomLine = showBottomLine
        self._isFav = .constant(isFav)
    }
    
    var body: some View {
        HStack(spacing: .xl) {
            TokenLogoView(
                currencySymbol: token?.currencySymbol,
                tokenName: token?.tokenName,
                isVerified: token?.isVerified,
                isFav: isFav
            )
            VStack(spacing: 4) {
                let adaName = token?.adaName
                let name = token?.projectName ?? ""
                HStack(spacing: 0) {
                    Text(adaName)
                        .font(.labelMediumSecondary)
                        .lineLimit(1)
                        .foregroundStyle(.colorBaseTent)
                    Spacer()
                    
                    if showSubPrice {
                        Text((token?.priceValue ?? 0).formatNumber(suffix: !showSubPrice ? Currency.ada.prefix : "", roundingOffset: token?.decimals))
                            .font(.labelMediumSecondary)
                            .foregroundStyle(.colorBaseTent)
                    } else {
                        let priceValue: AttributedString = {
                            switch appSetting.currency {
                            case Currency.ada.rawValue:
                                return (token?.priceValue ?? 0).formatNumber(suffix: Currency.ada.prefix)
                            default:
                                return (token?.priceValue ?? 0).formatNumber(prefix: Currency.usd.prefix)
                            }
                        }()
                        Text(priceValue)
                            .font(.labelMediumSecondary)
                            .foregroundStyle(.colorBaseTent)
                    }
                }
                HStack(spacing: 0) {
                    Text(name.isBlank ? adaName : name)
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                        .lineLimit(1)
                        .padding(.trailing, .md)
                    Spacer()
                    
                    if showSubPrice {
                        let subPrice: Double = token?.subPriceValue ?? 0
                        let subPriceValue: AttributedString = {
                            switch appSetting.currency {
                            case Currency.ada.rawValue:
                                return subPrice.formatNumber(suffix: Currency.ada.prefix, font: .paragraphSmall, fontColor: .colorInteractiveTentPrimarySub)
                            default:
                                return subPrice.formatNumber(prefix: Currency.usd.prefix, font: .paragraphSmall, fontColor: .colorInteractiveTentPrimarySub)
                            }
                        }()
                        Text(subPriceValue)
                            .layoutPriority(999)
                    } else {
                        let percentChange: Double = token?.percentChange ?? 0
                        if !percentChange.isZero {
                            HStack(spacing: 0) {
                                let foregroundStyle: Color = {
                                    guard !percentChange.isZero else { return .colorInteractiveTentPrimarySub }
                                    return percentChange > 0 ? .colorBaseSuccess : .colorBorderDangerDefault
                                }()
                                Text("\(abs(percentChange).formatSNumber(maximumFractionDigits: 2))%")
                                    .font(.labelSmallSecondary)
                                    .foregroundStyle(foregroundStyle)
                                if !percentChange.isZero {
                                    Image(percentChange > 0 ? .icUp : .icDown)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 14)
            .overlay(
                Rectangle().frame(height: 1).foregroundColor(showBottomLine ? .colorBorderItem : .clear), alignment: .bottom
            )
        }
        .padding(.horizontal, 16)
    }
}

struct TokenListItemSkeletonView: View {
    @State
    var showLogo: Bool = true
    
    var body: some View {
        HStack(spacing: .xl) {
            if showLogo {
                TokenLogoView(currencySymbol: nil, tokenName: nil, isVerified: false)
                    .skeleton(with: true, size: .init(width: 28, height: 28))
            }
            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    Text("")
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                .skeleton(with: true)
                .frame(height: 20)
                HStack(spacing: 0) {
                    Text("")
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                        .lineLimit(1)
                }
                .skeleton(with: true)
                .frame(height: 20)
            }
            .padding(.vertical, 12)
            .overlay(
                Rectangle().frame(height: 1).foregroundColor(.colorBorderItem), alignment: .bottom
            )
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    VStack(spacing: 0) {
        //        TokenListItemSkeletonView()
        TokenListItemView(token: TokenProtocolDefault(), showSubPrice: false)
        Spacer()
    }
    .environmentObject(AppSetting.shared)
}
