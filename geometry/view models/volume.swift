import SwiftUI
import MetalKit

struct Volume: View {
    @State private var view: MTKView
    @State private var renderer: Renderer?
    
    var body: some View {
        Representable(view: $view)
    }
    
    init(from section: CrossSection) {
        let view = MTKView()
        self.renderer = try? Renderer(from: section, to: view)
        self.view = view
    }
    
    struct Representable: NSViewRepresentable {
        @Binding var view: MTKView
        
        private func update() { }
        func makeNSView(context: Context) -> some NSView { view }
        func updateNSView(_ view: NSViewType, context: Context) { update() }
    }
}