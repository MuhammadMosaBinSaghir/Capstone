import SwiftUI
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
        guard self.count > 3 else { return Path() }
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
