import SwiftUI
import UniformTypeIdentifiers

struct TextExporter: View {
    @State private var exporting = false
    @State private var type: UTType? = nil
    
    @Environment(\.settings) private var settings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Grid(horizontalSpacing: 3, verticalSpacing: 0) {
            ForEach(Document.Structure.types, id: \.self) { type in
                GridRow(alignment: .center) {
                    Image("\(type.preferredFilenameExtension!)")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                    Text("." + type.preferredFilenameExtension!).stamp()
                }
                
                .onTapGesture {
                    exporting = true
                    self.type = type
                }
               
            }
            .fileExporter(
                isPresented: $exporting,
                documents: documents(of: type ?? .plainText),
                contentType: type ?? .plainText,
                onCompletion: completed
            )
        }
        .padding(6)
        .font(.system(size: 12, weight: .light, design: .monospaced))
    }
    
    private func documents(of type: UTType) -> [Document.Text] {
        return settings.selected.map {
            $0.formatted(.document(type, for: settings.structure))
        }
    }
    
    private var completed: (Result<[URL], Error>) -> Void { { result in
        switch result {
        case .success(_): break
        case .failure(let error): print(error.localizedDescription)
        }
        type = nil
        dismiss()
    } }
}
