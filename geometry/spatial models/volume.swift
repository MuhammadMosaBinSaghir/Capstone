import SwiftUI
import OrderedCollections

/// An approximation of a three-dimensional volume constructed by taking slices of an underlying shape.
///
/// Volumes are made up of loops and the unique planes on which said loops lie. Interpolation in between loops allows for a the creation of a blended volume.
///
/// - Note: Volumes are defined by at least 1 loop-plane pair.
struct Volume: Shape {
    let label: String
    var plane: Float
    /// The defining loops sorted based on the planes on which they lie.
    ///
    /// Loops are discrete 2-dimensional closed curves which are all assumed to exist in same coordinate-space.
    /// - Note: Interpolation requires that loops all contain the same number of points.
    let loops: [Loop]
    /// The planes on which a volume's loops lie.
    ///
    /// Planes are unique 1-dimensional positions that are located on an axis perpendicular to the loops' shared coordinate-space.
    /// - Note: Volumes are normalized to ensure that all planes fall within the range [0, 1].
    let planes: OrderedSet<Float>
    /// The position of the first element in either loops or planes.
    private let first: Int
    /// The position of the last element in either loops or planes.
    private let last: Int
    /// An anchor is the loop index that serves as the center of the ordinate axis for visualization.
    private let anchor: Loop.Index
    
    var animatableData: Float {
        get { plane }
        set { plane = newValue }
    }
    /// Conditionally initializes a volume from ordered loops and planes.
    /// - Note: Volumes are defined by at least 1 loop-plane pair and contain the same number of loops as planes.
    init?(_ label: String, with loops: [Loop], at planes: OrderedSet<Float>, showing plane: Float = .zero) {
        self.label = label
        self.plane = plane
        guard let decimated = loops.decimated(with: planes) else { return nil }
        let (planes, loops) = decimated.attributes.normalized(with: decimated.loops)
        self.loops = loops
        self.first = loops.startIndex
        self.last = loops.endIndex - 1
        self.anchor = loops[0].leading[0]
        self.planes = OrderedSet(planes)
    }
    
    func loop(at plane: Float) -> Loop {
        guard plane > planes[first] else { return loops[first] }
        guard plane < planes[last] else { return loops[last] }
        guard !planes.contains(plane) else { return loops[planes.firstIndex(of: plane)!] }
        let j = planes.firstIndex(where: { plane < $0 } )!, i = j - 1
        let front = loops[i].map { $0.projected(onto: planes[i]) }
        let back = loops[j].map { $0.projected(onto: planes[j]) }
        let interpolated = front.indices.map {
            Coordinate.located(between: front[$0], and: back[$0], at: plane)
        }
        return Loop(interpolated.map { $0.flat() })!
    }
    
    func path(in rect: CGRect) -> Path {
        return self.loop(at: plane).path(in: rect, anchor: self.anchor)
    }
}
