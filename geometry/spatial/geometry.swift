import SwiftUI
import UniformTypeIdentifiers

struct Mesh: FileDocument {
    var text = ""
    
    init(_ text: String = "") { self.text = text }
    
    static var readableContentTypes: [UTType] { [.text] }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else { throw URLError(.badURL)}
        text = String(decoding: data, as: UTF8.self)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
    
    enum Dimension { case second, third }
}
