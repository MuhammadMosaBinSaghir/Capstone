import SwiftUI
import UniformTypeIdentifiers

struct Popover: View {
    @Environment(\.settings) private var settings
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
            attachmentAnchor: .point(.bottomTrailing),
            arrowEdge: .trailing,
            content: { DocumentFormatter() }
        )
    }
}

struct DocumentFormatter: View {
    @State private var exporting = false
    @State private var format: Documents? = nil
    
    @Environment(\.settings) private var settings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Grid(horizontalSpacing: 3, verticalSpacing: 3) {
            ForEach(Documents.allCases, id: \.rawValue) { format in
                GridRow(alignment: .center) {
                    Text("." + format.rawValue).stamp()
                }
                .frame(height: 34)
                .onTapGesture {
                    exporting = true
                    self.format = format
                }
            }
            
            .fileExporter(
                isPresented: $exporting,
                documents: documents(kind: format),
                contentType: .plainText) { result in
                    switch result {
                        
                    case .success(let url): break
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    dismiss()
                }
        }
        .padding(6)
        .font(.system(size: 16, weight: .light, design: .monospaced))
    }
    
    func documents(kind: Documents?) -> [TextDocument] {
        guard let kind = kind else { return [] }
        let loops = settings.sections.selected.map {
            Loop(settings.model.loop(at: $0, smoothness: settings.model.smoothness))
        }
        return loops.map {
            $0.formatted(.document(kind: kind, structure: settings.structure))
        }
    }
}

/*
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
 */
