import Foundation

@frozen enum Documents: String, CaseIterable {
    case txt, csv, msh
    @frozen enum Errors: Error { case interrupted }
    
    @Observable class Structure {
        let precision: Int
        let units: UnitLength?
        let scale: Measurement<UnitLength>
        
        init(in units: UnitLength? = nil, precision: Int, scale: Measurement<UnitLength>) {
            self.precision = precision
            self.units = units
            self.scale = scale
        }
    }
}


//output parameters
//settings.

import SwiftUI
import UniformTypeIdentifiers

struct TextDocument: FileDocument {
    var text: String
    static var readableContentTypes = [UTType.plainText]

    init(_ text: String = "") { self.text = text }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents 
        else { throw Documents.Errors.interrupted }
        self.text = String(decoding: data, as: UTF8.self)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

extension Loop.Formatter where Output == TextDocument {
    static func document(kind: Documents, structure: Documents.Structure) -> Loop.Formatter<Output> {
        switch kind {
        case .csv:
            Self.init {
                let text = $0.formatted(.csv(
                    precision: structure.precision,
                    scale: structure.scale,
                    units: structure.units
                ))
               
                return TextDocument(text)
            }
        case .txt:
            Self.init {
                let text = $0.formatted(.txt(precision: structure.precision))
                return TextDocument(text)
            }
        case .msh:
            Self.init {
                let text = $0.mesh()
                return TextDocument(text)
            }
        }
        
    }
}

extension Loop {
    func mesh(radius: Float = 20, precision p: Int = 6) -> String {
        
        
        var mesh = self.enumerated().map {
            let x = $0.element.x.formatted(.number.precision(.significantDigits(p)))
            let y = $0.element.y.formatted(.number.precision(.significantDigits(p)))
            return "Point(\($0.offset + 1)) = { \(x), \(y), 0, 1 };\n"
        }.reduce("") { $0 + $1 }
        mesh.append("Point(\(self.count + 1)) = { 1, \(radius), 0, 1 };\n")
        mesh.append("Point(\(self.count + 2)) = { 1, \(-radius), 0, 1 };\n")
        mesh.append(
            "Point(\(self.count + 3)) = { \(-radius + 1), 0, 0, 1 };\n"
        )
        mesh.append(
            "Point(\(self.count + 4)) = { \(radius), \(radius), 0, 1 };\n"
        )
        guard let last = self.last?.y.formatted(.number.precision(.significantDigits(p)))
        else { return "" }
        mesh.append(
            "Point(\(self.count + 5)) = { \(radius), \(last), 0, 1 };\n"
        )
        mesh.append(
            "Point(\(self.count + 6)) = { \(radius), \(-radius), 0, 1 };\n"
        )
        mesh.append(
            "Point(\(self.count + 7)) = { 1, 0, 0, 1 };\n"
        )
        mesh.append(
            "Point(\(self.count + 8)) = {-1E-6, 0, 1, 1.0};\n"
        )
        let l = leading[0]
        mesh.append("Spline(1) = { ")
        for i in 1...(l + 1) { mesh.append("\(i.formatted(.number.grouping(.never))), ") }
        mesh.removeLast(2)
        mesh.append(" };\nSpline(2) = { ")
        for j in (l + 1)...(self.count - 1) { mesh.append("\(j.formatted(.number.grouping(.never))), ") }
        mesh.append(" 1 };\n")
        mesh.append("Line(3) = {1, \(self.count + 1)};\n")
        mesh.append("Line(4) = {1, \(self.count + 2)};\n")
        mesh.append("Line(5) = {\(l + 1), \(self.count + 3)};\n")
        mesh.append(
            "Circle(6) = {\(self.count + 1), \(self.count + 7), \(self.count + 3)};\n"
        )
        mesh.append(
            "Circle(7) = {\(self.count + 3), \(self.count + 7), \(self.count + 2)};\n"
        )
        mesh.append("Line(8) = {1 , \(self.count + 5)};\n")
        mesh.append("Line(9) = {\(self.count + 1), \(self.count + 4)};\n")
        mesh.append("Line(10) = {\(self.count + 2), \(self.count + 6)};\n")
        mesh.append("Line(11) = {\(self.count + 5), \(self.count + 6)};\n")
        mesh.append("Line(12) = {\(self.count + 5), \(self.count + 4)};\n")
        mesh.append("Line Loop(13) = {3, 6, -5, -1};\n")
        mesh.append("Line Loop(14) = {2, 4, -7, -5};\n")
        mesh.append("Line Loop(15) = {4, 10, -11, -8};\n")
        mesh.append("Line Loop(16) = {8, 12, -9, -3};\n")
        mesh.append("Surface(1) = {13};\n")
        mesh.append("Surface(2) = {-14};\n")
        mesh.append("Surface(3) = {15};\n")
        mesh.append("Surface(4) = {16};\n")
        mesh.append("Transfinite Line {1} = 100 Using Bump 0.05; // Airfoil Upper\n")
        mesh.append("Transfinite Line {2} = 100 Using Bump 0.05; // Airfoil Lower\n")
        mesh.append("Transfinite Line {6} = 100 Using Progression 1; // Farfield Up\n")
        mesh.append("Transfinite Line {7} = 100 Using Progression 1; // Farfield Down\n")
        mesh.append("Transfinite Line {3,5,4} = 175 Using Progression 1.086; // Lines\n")
        mesh.append("Transfinite Line {12,11} = 175 Using Progression 1.086; // Wake Vertical\n")
        mesh.append("Transfinite Line {8} = 50 Using Progression 1.175; // Wake Horizontal\n")
        mesh.append("Transfinite Line {9,10} = 50 Using Progression 1.175; // Wake Offset Horizontal\n")
        mesh.append("Transfinite Surface {1};\n")
        mesh.append("Transfinite Surface {2};\n")
        mesh.append("Transfinite Surface {3};\n")
        mesh.append("Transfinite Surface {4};\n")
        mesh.append("Recombine Surface{1};\n")
        mesh.append("Recombine Surface{2};\n")
        mesh.append("Recombine Surface{3};\n")
        mesh.append("Recombine Surface{4};\n")
        mesh.append("Physical Curve(\"AIRFOIL\", 17) = {2, 1};\n")
        mesh.append("Physical Curve(\"FARFIELD\", 18) = {6, 7, 10, 11, 12, 9};\n")
        mesh.append("Physical Surface(\"MESH\", 19) = {1, 2, 3, 4};\n")
        mesh.append("Mesh 2;")
        return mesh
    }
}
