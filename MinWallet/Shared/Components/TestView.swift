import SwiftUI
import UIKit
import SDWebImageSwiftUI

struct TestView: View {

    @State
    var isEnable: Bool = true
    var body: some View {
        VStack {
            CustomButton(
                title: "Swap",
                variant: .primary,
                icon: .icReceive,
                isEnable: $isEnable,
                action: {}
            )
            .frame(height: 40)
            Button {
                isEnable.toggle()
            } label: {
                Text("togle")
            }

        }
    }
}

#Preview {
    TestView()
}
