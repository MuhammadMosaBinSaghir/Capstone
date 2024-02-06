import SwiftUI
import OrderedCollections

/// An approximation of a three-dimensional volume constructed by taking slices of an underlying shape.
///
/// Models are made up of loops and the unique sections on which said loops lie. Interpolation in between loops allows for a the creation of a blended volume.
///
/// - Note: Models are defined by at least 1 loop-section pair.
@Observable class Model {
    let label: String
    var smoothness: Float
    /// The defining loops sorted based on the sections on which they lie.
    ///
    /// Loops are discrete 2-dimensional closed curves which are all assumed to exist in same coordinate-space.
    /// - Note: Interpolation requires that loops all contain the same number of points.
    let loops: [Loop]
    /// The sections on which a model's loops lie.
    ///
    /// Sections are unique 1-dimensional positions that are located on an axis perpendicular to the loops' shared coordinate-space.
    /// - Note: models are normalized to ensure that all sections fall within the range [0, 1].
    let sections: OrderedSet<Float>
    /// The position of the first element in either loops or sections.
    private let first: Int
    /// The position of the last element in either loops or sections.
    private let last: Int
    
    /// Conditionally initializes a model from ordered loops and sections.
    /// - Note: Models are defined by at least 1 loop-section pair and contain the same number of loops as sections.
    init?(_ label: String, with loops: [Loop], at sections: OrderedSet<Float>, smoothness λ: Float) {
        self.label = label
        self.smoothness = λ
        guard let decimated = loops.decimated(with: sections) else { return nil }
        let (sections, normed) = decimated.attributes.normalized(with: decimated.loops)
        self.loops = normed
        self.first = normed.startIndex
        self.last = normed.endIndex - 1
        self.sections = OrderedSet(sections)
    }
    
    func loop(at plane: Float, smoothness λ: Float = .zero) -> [Point] {
        guard plane > sections[first] else { return loops[first].smoothen(by: λ) }
        guard plane < sections[last] else { return loops[last].smoothen(by: λ) }
        guard !sections.contains(plane)
        else { return loops[sections.firstIndex(of: plane)!].smoothen(by: λ) }
        let j = sections.firstIndex(where: { plane < $0 } )!, i = j - 1
        let front = loops[i].smoothen(by: λ).map { $0.projected(onto: sections[i]) }
        let back = loops[j].smoothen(by: λ).map { $0.projected(onto: sections[j]) }
        let interpolated = front.indices.map {
            Coordinate.located(between: front[$0], and: back[$0], at: plane)
        }
        return interpolated.map { $0.flat() }
    }
    
    /*
    func loops(from sections: CrossSections) -> [Loop] {
        let filtered = self.sections.indices.filter { sections.region.contains(self.sections[$0])
        }
        let smooth = filtered.map { self.loops[$0].smoothen(by: self.smoothness) }
        return []
    }
    */
}
