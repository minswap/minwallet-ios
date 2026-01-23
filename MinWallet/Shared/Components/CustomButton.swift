import SwiftUI


struct CustomButton: View {
    var title: LocalizedStringKey
    var variant: Varriant = .primary
    var frameType: FrameType = .matchParent
    var icon: ImageResource? = nil
    var iconRight: ImageResource? = nil
    
    var action: () -> Void
    
    @Binding
    private var isEnable: Bool
    
    init(
        title: LocalizedStringKey,
        variant: Varriant = .primary,
        frameType: FrameType = .matchParent,
        icon: ImageResource? = nil,
        iconRight: ImageResource? = nil,
        isEnable: Binding<Bool> = .constant(true),
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.frameType = frameType
        self.icon = icon
        self.iconRight = iconRight
        self.action = action
        self._isEnable = isEnable
    }
    
    var body: some View {
        Button(action: {
            guard isEnable else { return }
            action()
        }) {
            HStack(spacing: Spacing.md) {
                if let icon = icon {
                    Image(icon)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                Text(title)
                    .font(.labelMediumSecondary)
                    .foregroundStyle(isEnable ? variant.textColor : variant.textColorDisable)
                    .lineLimit(1)
                    .layoutPriority(1)
                if let iconRight = iconRight {
                    Image(iconRight)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
            .frame(maxWidth: frameType == .matchParent ? .infinity : nil, maxHeight: .infinity)
            .padding(.horizontal, .lg)
            .background(isEnable ? variant.backgroundColor : variant.backgroundColorDisable)
            .shadow(radius: 50).cornerRadius(BorderRadius.full)
            .overlay(RoundedRectangle(cornerRadius: BorderRadius.full).stroke(variant.borderColor, lineWidth: 1))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        CustomButton(
            title: "Swap",
            variant: .primary,
            icon: .icReceive, action: {}
        )
        .frame(height: 40)
        CustomButton(
            title: "Swap",
            variant: .secondary,
            frameType: .matchParent,
            icon: .icSend, iconRight: .icUp, action: {}
        )
        .frame(height: 40)
    }
    .padding()
}


extension CustomButton {
    enum Varriant {
        case primary
        case secondary
        case other(
            textColor: Color,
            backgroundColor: Color,
            borderColor: Color,
            textColorDisable: Color?,
            backgroundColorDisable: Color?)
        
        var textColor: Color {
            switch self {
            case .primary:
                return .colorBaseTentNoDarkMode
            case .secondary:
                return .colorInteractiveTentSecondaryDefault
            case .other(let textColor, _, _, _, _):
                return textColor
            }
        }
        
        var textColorDisable: Color {
            switch self {
            case .primary:
                return .colorInteractiveTentSecondaryDisable
            case .secondary:
                return .colorInteractiveTentSecondaryDisable
            case let .other(_, _, _, textColor, _):
                return textColor ?? .colorInteractiveTentSecondaryDisable
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return .colorInteractiveTonePrimary
            case .secondary:
                return .clear
            case .other(_, let backgroundColor, _, _, _):
                return backgroundColor
            }
        }
        
        var backgroundColorDisable: Color {
            switch self {
            case .primary:
                return .colorSurfacePrimaryDisable
            case .secondary:
                return .colorSurfacePrimaryDisable
            case let .other(_, _, _, _, backgroundColor):
                return backgroundColor ?? .colorSurfacePrimaryDisable
            }
        }
        
        var borderColor: Color {
            switch self {
            case .primary:
                return .clear
            case .secondary:
                return .colorInteractiveTentSecondarySub
            case .other(_, _, let borderColor, _, _):
                return borderColor
            }
        }
    }
    
    enum FrameType {
        case wrapContent
        case matchParent
    }
}
