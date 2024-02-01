import SwiftUI
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
    func path(in rect: CGRect) -> Path {
        guard self.count >= 3 else { return Path() }
        let leading = CGPoint(x: rect.minX, y: rect.midY)
        let flattened = self.map { Point($0.x, $0.y) }
        let scaled = flattened.map { $0 * rect.width.vectored() + leading.vectored() }
        let flipped = scaled.map { Point(x: $0.x, y: rect.maxY.vectored() - $0.y) }
        let graphed = flipped.map { $0.graphed() }
        var path = Path()
        path.move(to: graphed[0])
        graphed.forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
    func smoothen(by λ: Float, repetitions: Int) -> Self {
        guard !λ.isZero else { return self }
        guard λ > 0 && repetitions >= 1 else { return Self() }
        let count = (long: self.count, short: Int32(self.count))
        let factorized =
        SparseOpaqueFactorization_Float.Laplacian(factor: λ, size: count.long)
        var p = self.map { $0.x } + self.map { $0.y }
        let size = p.count
        (1...repetitions).forEach { _ in
            let q = [Float](unsafeUninitializedCapacity: 2 * count.long) { buffer, sized in
                p.withUnsafeMutableBufferPointer { pointer in
                    let P = DenseMatrix_Float(rowCount: count.short, columnCount: 2, columnStride: count.short, attributes: SparseAttributes_t(), data: pointer.baseAddress!)
                    let Q = DenseMatrix_Float(rowCount: count.short, columnCount: 2, columnStride: count.short, attributes: SparseAttributes_t(), data: buffer.baseAddress!)
                    SparseSolve(factorized, P, Q)
                    sized = size
                }
            }
            p = q
        }
        return self.indices.map { Element(p[$0], p[count.long + $0]) }
    }
}

extension OrderedSet: SpatialCollection where Element: Positionable {
    func text(precision digits: Int = 6) -> String {
        self.elements.text(precision: digits)
    }
    func path(in rect: CGRect) -> Path { self.elements.path(in: rect) }
}

extension Loop: SpatialCollection {
    init?(_ points: [Point]) { self.init(OrderedSet(points)) }
    
    func text(precision digits: Int = 6) -> String {
        self.points.text(precision: digits)
    }
}
