import Foundation

extension Loop {
    /// Determines which interior angles make up a loop.
    func angles() -> [Angle] {
        return self.indices.map { self[$0 - 1].dot(self[$0 + 1], from: self[$0]) }
    }
    /// Determines the areas formed by each point and its immediate neighbors.
    func areas() -> [Area] {
        self.indices.map { self[$0 - 1].area(to: self[$0 + 1], from: self[$0]) }
    }
    /// Decimates the loop by removing a given number of points.
    ///
    /// Implements the Visvalingam–Whyatt algorithm to iteratively remove points based on their contribution to the overall loop's area. In this implementation, removing a point only requires recomputing the areas formed by its two nearest neighbors.
    func decimated(removing iterations: Loop.Index) -> Self? {
        guard iterations > 0 else { return nil }
        guard self.count - iterations >= 3 else { return nil }
        var points = self.points
        var areas = self.areas()
        for _ in (1...iterations) {
            var minimized = areas.enumerated().sorted(by: \.element.magnitude)
            let i = minimized.removeFirst().offset
            let _ = areas.remove(at: i)
            let _ = points.remove(at: i)
            let endIndex = points.endIndex
            let g = (i - 2) %% endIndex
            let h = (i - 1) %% endIndex
            let j = i %% endIndex
            let k = (i + 1) %% endIndex
            areas[h] = points[g].area(to: points[j], from: points[h])
            areas[j] = points[h].area(to: points[k], from: points[j])
        }
        return Loop(points)
    }
}
