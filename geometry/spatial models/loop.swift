import SwiftUI
import OrderedCollections

/// A representation of a closed curve formed by a collection of unique points.
///
/// Loops are immutable collections of points that represent closed discrete curves. The points within a loop are unique and ordered in an anticlockwise manner. The lengths of the loops are always normalized, ensuring that all x-coordinates fall within the range [0, 1].
///
/// - Note: Loops are defined by at least 3 unique coordinates.

struct Loop: Hashable, Shape {
    typealias Index = Int
    typealias Element = Point

    /// The normalized oriented area enclosed by the loop.
    let area: Area
    /// The distance between the loop's first trailing edge and its first leading edge.
    let chord: Float
    /// An ordered set of indices, whose associated points have coordinates (0, y).
    let leading: OrderedSet<Index>
    /// An ordered set of indices, whose associated points have coordinates (1, y).
    let trailing: OrderedSet<Index>
    /// The domain of a loop's ordinates.
    let ordinates: ClosedRange<Float>
    /// The domain of a loop's abscissas.
    /// - Note: This domain always corresponds to [0, 1].
    let abscissas: ClosedRange<Float> = 0...1
    
    let points: OrderedSet<Point>
    /// The index of the loop's first trailing edge.
    let startIndex: Index
    /// The index after which is the loop's first trailing edge.
    let endIndex: Index

    @frozen enum Orientation { case clockwise, anticlockwise }
    struct Area: Hashable {
        let magnitude: Float, orientation: Orientation
        init(_ area: Float) {
            self.magnitude = abs(area)
            self.orientation = area > 0 ? .anticlockwise : .clockwise
        }
        init(_ magnitude: Float, oriented: Orientation) {
            self.magnitude = magnitude
            self.orientation = oriented
        }
    }
    
    /// Conditionally initializes a loop from an ordered set of points.
    /// - Note: Loops are defined by at least 3 unique coordinates.
    init?(_ set: OrderedSet<Point>) {
        guard set.count >= 3 else { return nil }
        guard let area = set.area() else { return nil }
        let oriented = set.oriented(as: .anticlockwise, given: area)
        let abscissed = oriented.enumerated().sorted { $0.element.x < $1.element.x }
        let front = abscissed.first!, back = abscissed.last!, count = oriented.count
        let offset = oriented.indices.map { oriented[($0 + back.offset)%count] }
        let leading = offset.indices.filter { offset[$0].x == front.element.x }
        let trailing = offset.indices.filter { offset[$0].x == back.element.x }
        let zeroed = offset.zeroed(between: leading.first!, and: leading.last!)
        let length = zeroed[trailing[0]].x
        let normalized = zeroed.map { $0/length }
        let ordinated = normalized.sorted { $0.y < $1.y }
        self.points = OrderedSet(normalized)
        self.startIndex = normalized.startIndex
        self.endIndex = normalized.endIndex
        self.leading = OrderedSet(leading)
        self.trailing = OrderedSet(trailing)
        self.chord = normalized[trailing[0]].distance(to: normalized[leading[0]])
        self.ordinates = ordinated.first!.y...ordinated.last!.y
        self.area = Area(area.magnitude/(length*length), oriented: .anticlockwise)
    }
    
    func index(after i: Index) -> Index { points.index(after: i) }
    func index(before i: Index) -> Index { points.index(before: i) }
    /// Retrives points making up a loop
    ///
    /// Loops will wrap around themselves for any value greater than the endIndex or smaller than the startIndex.
    /// - Note: Any integer can be used to index a loop.
    subscript(index: Index) -> Element { return points[index %% endIndex] }
    
    /// A loop equals another loop when both represent a single polygon that lies on a single plane.
    static func == (lhs: Loop, rhs: Loop) -> Bool { lhs.points == rhs.points }
    func hash(into hasher: inout Hasher) { hasher.combine(points) }
    
    func path(in rect: CGRect) -> Path { self.points.path(in: rect) }
    
    func path(in rect: CGRect, anchor: Loop.Index) -> Path {
        let anchored = self.map { Point(x: $0.x, y: $0.y - self[anchor].y) }
        return anchored.path(in: rect)
    }
}
