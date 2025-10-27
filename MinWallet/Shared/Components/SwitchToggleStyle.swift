import SwiftUI


struct SwitchToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Image(configuration.isOn ? .icToggleOn : .icToggleOff)
        }
        .buttonStyle(.plain)
    }
}
