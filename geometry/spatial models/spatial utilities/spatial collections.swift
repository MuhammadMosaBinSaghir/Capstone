import Accelerate
import OrderedCollections

extension Collection where Element == Loop, Index == Int {
    func decimated<C: Collection>(with attributes: C) -> (loops: [Element], attributes: [C.Element])? where C.Index == Int {
        guard !self.isEmpty && self.count == attributes.count else { return nil }
        let (jagged, minimum, _) = self.isJagged()
        guard let downsized = minimum else { return nil }
        guard jagged
        else { return (Array(self), Array(attributes)) }
        let zipped = zip(self, attributes).compactMap { (loop, plane) in
            let count = loop.count
            guard count != minimum else { return (loop, plane) }
            guard let decimated = loop.decimated(removing: count - downsized)
            else { return nil }
            return (decimated, plane)
        }
        guard !zipped.isEmpty else { return nil }
        return (zipped.map { $0.0 }, zipped.map { $0.1 })
    }
}

extension Array: SpatialCollection where Element: Positionable {
    struct Formatter<Output> { let format: ([Element]) -> Output }
    
    func formatted<Output>(_ formatter: Formatter<Output>) -> Output {
        return formatter.format(self)
    }
    
    func inversed(close: Bool = false) -> Self {
        var reversed: [Element] = self.reversed()
        let last = reversed.removeLast()
        let opened = [last] + reversed
        return close ? opened + [last] : opened
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
    struct Formatter<Output> { let format: (OrderedSet<Element>) -> Output }
    
    func formatted<Output>(_ formatter: Formatter<Output>) -> Output {
        return formatter.format(self)
    }
    /// Smooths out a curve based on its Laplacian
    /// - Note: Coordinates are always projected back onto the XY-plane, losing their depth.
    func smoothen(by λ: Float) -> [Element] { self.elements.smoothen(by: λ) }
}

extension Loop: SpatialCollection {
    init(_ points: [Point]) { self.init(OrderedSet(points)) }
    /// Smooths out a curve based on its Laplacian
    /// - Note: Coordinates are always projected back onto the XY-plane, losing their depth.
    func smoothen(by λ: Float) -> [Point] { self.points.smoothen(by: λ) }
}
