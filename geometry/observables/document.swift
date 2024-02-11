import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    public static var geo: UTType {
        UTType(importedAs: "org.zeus.gmsh")
    }
}
struct Document {
    @frozen enum Errors: Error { case interrupted }
    
    @Observable class Structure {
        let precision: Int
        let units: UnitLength?
        let scale: Measurement<UnitLength>
        static let types: [UTType] = [.plainText, .commaSeparatedText, .geo]
        
        init(in units: UnitLength? = nil, precision: Int, scale: Measurement<UnitLength>) {
            self.precision = precision
            self.units = units
            self.scale = scale
        }
    }
    
    struct Text: FileDocument {
        var contents: String
        static var readableContentTypes: [UTType] = [.plainText, .commaSeparatedText, .geo]
        
        init(_ contents: String = "") { self.contents = contents }
        
        init(configuration: ReadConfiguration) throws {
            guard let data = configuration.file.regularFileContents
            else { throw Errors.interrupted }
            self.contents = String(decoding: data, as: UTF8.self)
        }
        
        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            let data = Data(contents.utf8)
            return FileWrapper(regularFileWithContents: data)
        }
    }
}

extension Loop.Formatter where Output == Document.Text {
    static func document(_ type: UTType, for structure: Document.Structure) -> Loop.Formatter<Document.Text> {
        switch type {
        case .commaSeparatedText: Self.init {
            let contents = $0.formatted(.csv(precision: structure.precision, scale: structure.scale, units: structure.units))
            return Document.Text(contents)
        }
            
        case .geo: Self.init {
            let contents = $0.mesh(radius: 20, precision: structure.precision)
            return Document.Text(contents)
        }
            
        default: Self.init {
            let contents = $0.formatted(.txt(precision: structure.precision))
            return Document.Text(contents)
        } }
    }
}
