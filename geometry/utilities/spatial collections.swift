import Accelerate
import OrderedCollections

extension Array: SpatialCollection where Element: Positionable {
    func text(precision digits: Int = 6) -> String {
        let points = self.map { $0.text(precision: digits) }
        var text = points.reduce("[") { $0 + $1 }
        text.removeLast()
        text.append("]")
        return text
    }
    /// Smooths out a curve based on its Laplacian
    /// - Note: Coordinates are always projected back onto the XY-plane, losing their depth.
    func smoothen(by λ: Float) -> Self {
        guard !λ.isZero else { return self }
        guard λ > 0 else { return Self() }
        let count = (long: self.count, short: Int32(self.count))
        let factorized =
        SparseOpaqueFactorization_Float.Laplacian(factor: λ, size: count.long)
        var p = self.map { $0.x } + self.map { $0.y }
        SparseSolver.Laplacian(of: &p, count: count, factorization: factorized)
        return self.indices.map { Element(p[$0], p[count.long + $0]) }
    }
}

extension OrderedSet: SpatialCollection where Element: Positionable {
    func text(precision digits: Int = 6) -> String {
        self.elements.text(precision: digits)
    }
    /// Smooths out a curve based on its Laplacian
    /// - Note: Coordinates are always projected back onto the XY-plane, losing their depth.
    func smoothen(by λ: Float) -> [Element] { self.elements.smoothen(by: λ) }
}

extension Loop: SpatialCollection {
    init(_ points: [Point]) { self.init(OrderedSet(points)) }
    
    func text(precision digits: Int = 6) -> String {
        self.points.text(precision: digits)
    }
    /// Smooths out a curve based on its Laplacian
    /// - Note: Coordinates are always projected back onto the XY-plane, losing their depth.
    func smoothen(by λ: Float) -> [Point] { self.points.smoothen(by: λ) }
}
