import SwiftUI

enum Span: String, CaseIterable {
    case base, quater, middle, third, wingtip, split
    
    func file() -> String {
        switch self {
        case .base: return "Cessna-0.00.geo"
        case .quater: return "Cessna-0.25.geo"
        case .middle: return "Cessna-0.50.geo"
        case .third: return "Cessna-0.75.geo"
        case .wingtip: return "Cessna-1.00.geo"
        case .split: return "Cessna-?.??.geo"
        }
    }
    func contour() -> [Point] {
        switch self {
        case .base: return [Point](Library.base)
        case .middle: return [Point](Library.middle)
        case .third: return [Point](Library.third)
        case .wingtip: return [Point](Library.wingtip)
        case .split: return [Point](Library.split)
        default: return [Point](Library.base)
        }
    }
}

struct Content: View {
    @State var knots: Int = 0
    @State var span: Span = .middle
    @State var type: Spline = .centripetal
    @State var text: String = [Point](Library.middle).mesh()
    
    @State private var meshing = false
    private let manager = FileManager.default
    
    var body: some View {
        TextEditor(text: $text)
            .onChange(of: span) { update() }
            .onChange(of: type) { update() }
            .onChange(of: knots) { update() }
            .toolbar {
                ToolbarItem {
                    Picker("span", selection: $span) {
                        ForEach(Span.allCases, id: \.self) { Text($0.rawValue) }
                    }
                }
                ToolbarItem {
                    Picker("spline", selection: $type) {
                        ForEach(Spline.allCases, id: \.self) { Text($0.rawValue) }
                    }
                }
                ToolbarItem {
                    Picker("knots", selection: $knots) {
                        ForEach(0...20, id: \.self) { Text("\($0)") }
                    }
                }
                ToolbarItem() {
                    Button {
                        meshing = true
                    } label: {
                        Label("Export file", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .fileExporter(isPresented: $meshing, document: Mesh(text), contentType: .text, defaultFilename: span.file()) { _ in }
    }
    
    private func update() {
        let contour: [Point]
        switch knots {
        case 0: contour = span.contour()
        default: contour = span.contour().spline(type, by: knots)
        }
        text = contour.mesh()
    }
    
    private func export() {
        let desktop = manager.urls(for: .desktopDirectory, in: .userDomainMask)
        let url = desktop[0].appendingPathComponent("Cessna-0.00.geo")
        guard let bits = text.data(using: .utf8) else { return }
        try? bits.write(to: url)
    }
}

#Preview { Content() }
