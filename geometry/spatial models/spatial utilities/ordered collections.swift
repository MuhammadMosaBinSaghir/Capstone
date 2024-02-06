import Foundation

extension OrderedCollection where Element == Point {
    func area() -> Loop.Area? {
        guard Set(self).count >= 3 else { return nil }
        let last = self.count - 1
        let closed = self[0] == self[last]
        let vertices = closed ? 0...(last - 1) : 0...last
        let area: Float = vertices.reduce(into: 0) { area, index in
            let assessed = self[index]
            let adjacent = self[(index + 1) % self.count]
            area += (assessed.x * adjacent.y) - (assessed.y * adjacent.x)
        }
        guard !area.isZero else { return nil }
        return Loop.Area(0.5*area)
    }
    func orientation() -> Loop.Orientation? {
        guard let area = self.area() else { return nil }
        return area.orientation
    }
    func oriented(as desired: Loop.Orientation, given area: Loop.Area) -> Self {
        switch area.orientation == desired {
        case true: return self
        case false: return self.reversal()
        }
    }
    func oriented(to: Loop.Orientation, from: Loop.Orientation) -> Self {
        switch from == to {
        case true: return self
        case false: return self.reversal()
        }
    }
    func oriented(as desired: Loop.Orientation) -> Self {
        guard let orientation = self.orientation() else { return self.emptied() }
        return oriented(to: desired, from: orientation)
    }
    func zeroed(between front: Index, and back: Index) -> [Element] {
        guard self.indices.contains(front) && self.indices.contains(back)
        else { return [] }
        let leading = 0.5 * (self[front] + self[back])
        return self.map { $0 - leading }
    }
}
