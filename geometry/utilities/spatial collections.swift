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
    // assumes that the order of the list has meaning, such as you want when at 5, you want to sample 4 and 6 for example, even if 1 is closer in euclidyan distance. I.E. the points you gave are assumed to be sorted in terms of closest parametric distance.
    // all other rules
    // non-optimal because I can be using the FFT to get this down from O(km) to O^(k*log(k)). However that's really more useful for large window sizes where m -> k and where k -> ∞. k is not the widow size but the siuze of (lowerbound...upperbound) which is not equal to n, which is the input array. The worst case scenerio is w = k which is are both equal to n/2 + 1. So it'd be 0((n/2 + 1) * (n/2 + 1)) I think. It'd be 22 times faster on our array size of 200 at best and 87 times faster at worst.
    func convolve(with kernel: Kernel) -> Self? {
        guard self.count >= 3 else { return nil }
        guard kernel.count >= 3 else { return nil }
        guard kernel.count % 2 == 1 else { return nil }
        guard !kernel.weights.isEmpty else { return nil }
        let firstIndex = startIndex, lastIndex = endIndex - 1, half = kernel.count/2
        let lowerBound = firstIndex + half, upperBound = lastIndex - half
        guard lowerBound <= upperBound else { return nil }
        let weights = kernel.weights, summed = weights.reduce(0, +)
        let convolved = (lowerBound...upperBound).map { i in
            let selected = ((i - half)...(i + half)).map { self[$0] }
            let weighted = selected.indices.map { weights[$0] * selected[$0] }
            return weighted.reduce(Element.zero, +)/summed
        }
        let front = (firstIndex..<lowerBound).map { self[$0] }
        let back = ((upperBound + 1)...lastIndex).map { self[$0] }
        return front + convolved + back
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
