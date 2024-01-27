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
