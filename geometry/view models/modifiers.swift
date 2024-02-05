import SwiftUI

struct Transparent: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Self.Representable())
    }
    
    struct Representable: NSViewRepresentable {
        func updateNSView(_ nsView: NSView, context: Context) {}
        func makeNSView(context: Self.Context) -> NSView {
            let transparency = NSVisualEffectView()
            transparency.material = .popover
            transparency.state = .active
            return transparency
        }
    }
}

struct Stamp: ViewModifier {
    @Environment(\.colorScheme) var scheme
    
    func body(content: Content) -> some View {
        content
            .padding(6)
            .foregroundStyle(.white)
            .background(.stamp(in: scheme))
            .clipShape(.rect(cornerRadius: 6))
    }
}
