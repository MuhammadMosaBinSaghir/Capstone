import Foundation
import OrderedCollections

extension Array: SpatialCollection where Element == Point {
    init(_ text: String) {
        let split = text.split(separator: "\n").map { $0.split(separator: ",") }
        self = split.map { Point(x: Float($0[0]) ?? 0, y: Float($0[1]) ?? 0) }
    }
    func text(precision digits: Int = 6) -> String {
        let points = self.map {
            "(\($0.x.formatted(.number.precision(.significantDigits(digits)))), \($0.y.formatted(.number.precision(.significantDigits(digits))))),"
        }
        var text = points.reduce("[") { $0 + $1 }
        text.removeLast()
        text.append("]")
        return text
    }
}

extension OrderedSet: SpatialCollection where Element == Point {
    init(_ text: String) { self = OrderedSet([Point].init(text)) }
    func text(precision digits: Int = 6) -> String {
        self.elements.text(precision: digits)
    }
}

extension Loop: SpatialCollection {
    init?(_ text: String) { self.init(OrderedSet(text)) }
    init?(_ points: [Point]) { self.init(OrderedSet(points)) }
    
    func text(precision digits: Int = 6) -> String {
        self.points.text(precision: digits)
    }
}
