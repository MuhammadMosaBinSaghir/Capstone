import SwiftUI

struct DocumentSelector: View {
    @State private var popped = false
    
    var body: some View {
        Button(action: {
            popped = true
        }, label: {
            Label("Documents", systemImage: "square.and.arrow.up")
                .imageScale(.large)
        })
        .focusEffectDisabled()
        .buttonStyle(.stamped)
        .popover(
            isPresented: $popped,
            attachmentAnchor: .point(.center),
            arrowEdge: .bottom,
            content: { TextExporter() }
        )
    }
}
