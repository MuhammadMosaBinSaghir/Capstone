import Foundation

@Observable class Settings {
    var sections = CrossSections(in: 0...1, select: 5)
    var model = Model(
        "Cessna Citation X",
        with: replicated.map { Loop($0) },
        at: [0, 0.25, 0.5, 0.75, 1], 
        smoothness: 3
    )!
    var structure =
    Documents.Structure(
        precision: 6,
        scale: Measurement(value: 25, unit: .millimeters)
    )
}
