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
    
    // Non working Visvalingam–Whyatt algorithm
    func decimated(removing iterations: Loop.Index) -> Self? {
        guard iterations > 0 else { return nil }
        guard self.count - iterations >= 3 else { return nil }
        var points = self.points
        var areas = self.areas().enumerated().sorted(by: \.element.magnitude)
        for _ in (1...iterations) {
            let i = areas.removeFirst().offset
            let _ = points.remove(at: i)
            let maximum = points.endIndex
            var offset = areas.map {
                (offset: $0.offset < i ? $0.offset : $0.offset - 1, element: $0.element)
            }
            let h = (i - 1) %% maximum
            let j = i %% maximum
            guard let H = offset.firstIndex(where: { $0.offset == h }) else { return nil }
            guard let J = offset.firstIndex(where: { $0.offset == j }) else { return nil }
            offset[H].element = self[h - 1].area(to: self[j], from: self[h])
            offset[J].element = self[h].area(to: self[j + 1], from: self[j])
            areas = offset.sorted(by: \.element.magnitude)
        }
        return Loop(points)
    }
    
    // Working Visvalingam–Whyatt algorithm
    func streamlined(to size: Loop.Index) -> Self {
        guard self.count > size else { return self }
        var areas = self.areas()
        var points = self.points
        areas.removeAll(where: { $0.magnitude.isEqual(to: .zero) })
        guard let smallest = areas.min(by: { $0.magnitude < $1.magnitude })
        else { return self }
        guard let index = areas.firstIndex(where: { $0 == smallest } )
        else { return self }
        points.remove(at: index)
        // don't create a new loop until the end
        guard let decimated = Loop(points) else { return self }
        return decimated.streamlined(to: size)
    }
}
