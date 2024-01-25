import Foundation

extension Loop {
    
    /// Determines which interior angles make up a loop.
    func angles() -> [Angle] {
        return self.indices.map { self[$0 - 1].dot(self[$0 + 1], from: self[$0]) }
    }
    
    // Has a perference for picking the last decimated index.
    func decimated(removing iterations: Int) -> Self? {
        guard self.count - iterations >= 3 else { return nil }
        var points = self.points
        var angles = self.angles().enumerated().sorted { $0.element > $1.element }
        for I in (1...iterations) {
            let i = angles.removeFirst().offset
            let _ = points.remove(at: i)
            let maximum = points.endIndex
            var offset = angles.map {
                (offset: $0.offset < i ? $0.offset : $0.offset - 1, element: $0.element)
            }
            let h = (i - 1) %% maximum
            let j = i %% maximum
            guard let H = offset.firstIndex(where: { $0.offset == h }) else { return nil }
            guard let J = offset.firstIndex(where: { $0.offset == j }) else { return nil }
            offset[H].element = self[h - 1].dot(self[j], from: self[h])
            offset[J].element = self[h].dot(self[j + 1], from: self[j])
            angles = offset.sorted { $0.element > $1.element }
        }
        return Loop(points)
    }
}
