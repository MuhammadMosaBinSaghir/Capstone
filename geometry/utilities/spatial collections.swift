import SwiftUI
import Algorithms
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
    func convolve(with kernel: Kernel) -> Self? {
        guard self.count >= 3 else { return nil }
        let window = kernel.window
        let delimited = ((startIndex + 1)...(endIndex - 2)).map { self[$0] }
        let abscissas = vDSP.convolve(delimited.map { $0.x }, withKernel: window)
        let ordinates = vDSP.convolve(delimited.map { $0.y }, withKernel: window)
        let elements = zip(abscissas, ordinates).map { Element($0, $1) }
        return [self[0]] + elements + [self[endIndex - 1]]
    }
}

extension OrderedSet: SpatialCollection where Element: Positionable {
    func text(precision digits: Int = 6) -> String {
        self.elements.text(precision: digits)
    }
    func path(in rect: CGRect) -> Path { self.elements.path(in: rect) }
    func convolve(with kernel: Kernel) -> Self? {
        guard let convolved = self.elements.convolve(with: kernel)
        else { return nil }
        return OrderedSet(convolved)
    }
}

extension Loop: SpatialCollection {
    init?(_ points: [Point]) { self.init(OrderedSet(points)) }
    
    func text(precision digits: Int = 6) -> String {
        self.points.text(precision: digits)
    }
    
    //MAkE SURE all collections [3]
    
    func convolve(with kernel: Kernel) -> Self? {
        let extremities = leading.union(trailing).sorted()
        guard let last = extremities.last else { return nil }
        let paired = extremities.adjacentPairs().map { $0.0...$0.1 }
        let closed = paired + [last...endIndex]
        let convolved = closed.reduce(into: [Point]()) { points, range in
            let mapped = range.map { self[$0] }
            guard let convolved = mapped.convolve(with: kernel) else {
                points.append(contentsOf: mapped)
                return
            }
            points.append(contentsOf: convolved)
        }
        return Loop(OrderedSet(convolved))
    }
}
