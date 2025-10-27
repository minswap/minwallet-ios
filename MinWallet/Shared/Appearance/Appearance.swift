import SwiftUI

enum Appearance: Int, CaseIterable, Identifiable {
    case light
    case dark
    case system
    
    var id: String { UUID().uuidString }
}
