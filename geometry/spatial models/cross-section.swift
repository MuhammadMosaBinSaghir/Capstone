import SwiftUI
import OrderedCollections

/// An approximation of a three-dimensional volume constructed by taking slices of an underlying shape.
///
/// Cross-sections are made up of loops and the unique planes on which said loops lie. Interpolation in between loops allows for a the creation of a blended volume.
///
/// - Note: Cross-sections are defined by at least 1 loop-plane pair.
struct CrossSection: Shape {
    let label: String
    var plane: Float
    var smoothness: Float
    /// The defining loops sorted based on the planes on which they lie.
    ///
    /// Loops are discrete 2-dimensional closed curves which are all assumed to exist in same coordinate-space.
    /// - Note: Interpolation requires that loops all contain the same number of points.
    let loops: [Loop]
    /// The planes on which a cross-section's loops lie.
    ///
    /// Planes are unique 1-dimensional positions that are located on an axis perpendicular to the loops' shared coordinate-space.
    /// - Note: Cross-sections are normalized to ensure that all planes fall within the range [0, 1].
    let planes: OrderedSet<Float>
    /// The position of the first element in either loops or planes.
    private let first: Int
    /// The position of the last element in either loops or planes.
    private let last: Int
    
    var animatableData: AnimatablePair<Float, Float> {
        get { AnimatablePair(plane, smoothness) }
        set { plane = newValue.first; smoothness = newValue.second }
    }
    /// Conditionally initializes a cross-section from ordered loops and planes.
    /// - Note: Cross-sections are defined by at least 1 loop-plane pair and contain the same number of loops as planes.
    init?(_ label: String, with loops: [Loop], at planes: OrderedSet<Float>, showing plane: Float = .zero, smoothness λ: Float = .zero) {
        self.label = label
        self.plane = plane
        self.smoothness = λ
        guard let decimated = loops.decimated(with: planes) else { return nil }
        let (planes, normed) = decimated.attributes.normalized(with: decimated.loops)
        self.loops = normed
        self.first = normed.startIndex
        self.last = normed.endIndex - 1
        self.planes = OrderedSet(planes)
    }
    
    func loop(at plane: Float, smoothness λ: Float = .zero) -> [Point] {
        guard plane > planes[first] else { return loops[first].smoothen(by: λ) }
        guard plane < planes[last] else { return loops[last].smoothen(by: λ) }
        guard !planes.contains(plane)
        else { return loops[planes.firstIndex(of: plane)!].smoothen(by: λ) }
        let j = planes.firstIndex(where: { plane < $0 } )!, i = j - 1
        let front = loops[i].smoothen(by: λ).map { $0.projected(onto: planes[i]) }
        let back = loops[j].smoothen(by: λ).map { $0.projected(onto: planes[j]) }
        let interpolated = front.indices.map {
            Coordinate.located(between: front[$0], and: back[$0], at: plane)
        }
        return interpolated.map { $0.flat() }
    }
    
    func graph(in rect: CGRect, at plane: Float, smoothness λ: Float = .zero) -> [CGPoint] {
        let points = loop(at: plane, smoothness: λ)
        let leading = CGPoint(x: rect.minX, y: rect.midY)
        let scaled = points.map { $0 * rect.width.ungraphed() + leading.vectored() }
        let flipped = scaled.map {
            Point(x: $0.x, y: rect.maxY.ungraphed() - $0.y)
        }
        return flipped.map { $0.graphed() }
    }
    
    func normals(in rect: CGRect) -> Path {
        let baseline = self.graph(in: rect, at: plane)
        let smooth = self.graph(in: rect, at: plane, smoothness: smoothness)
        var path = Path()
        baseline.indices.forEach {
            path.move(to: baseline[$0])
            path.addLine(to: smooth[$0])
        }
        path.closeSubpath()
        return path
    }
    
    func path(in rect: CGRect) -> Path {
        let graphed = self.graph(in: rect, at: plane, smoothness: smoothness)
        var path = Path()
        path.move(to: graphed[0])
        graphed.forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
}
