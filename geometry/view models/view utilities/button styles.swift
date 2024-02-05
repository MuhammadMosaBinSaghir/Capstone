import SwiftUI

extension ButtonStyle where Self == Stamped {
    static var stamped: Stamped { Stamped() }
}

struct Stamped: ButtonStyle {
    @Environment(\.colorScheme) var scheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .stamp()
            .labelStyle(.iconOnly)
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .animation(.bouncy, value: configuration.isPressed)
    }
}
