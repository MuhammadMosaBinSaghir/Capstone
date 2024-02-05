import SwiftUI

struct Popover: View {
    @State private var popped = false
    
    var body: some View {
        Button(action: {
            popped = true
        }, label: {
            Label("Documents", systemImage: "square.and.arrow.up")
                .font(.title)
                .imageScale(.large)
        })
        .focusEffectDisabled()
        .buttonStyle(.stamped)
        .popover(
            isPresented: $popped,
            attachmentAnchor: .point(.top),
            arrowEdge: .top,
            content: { Contents() }
        )
    }
    
    struct Contents: View {
        @Environment(\.dismiss) private var dismiss
        var body: some View {
            Grid(horizontalSpacing: 3, verticalSpacing: 3) {
                ForEach(Mesh.Formats.allCases, id: \.rawValue) { format in
                    GridRow(alignment: .center) {
                        Image(format.rawValue)
                            .resizable()
                            .scaledToFit()
                        Text("." + format.rawValue).stamp()
                    }
                    .frame(height: 34)
                    .onTapGesture { dismiss() }
                }
            }
            .padding(6)
            .font(.system(size: 16, weight: .light, design: .monospaced))
        }
    }
}
