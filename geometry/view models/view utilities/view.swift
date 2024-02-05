import SwiftUI

extension View {
    func transparent() -> some View { modifier(Transparent()) }
    func stamp() -> some View { modifier(Stamp()) }
}
