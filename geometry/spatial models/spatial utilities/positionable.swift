import Foundation

extension Point: Positionable {
    func commaed(precision digits: Int = 6) -> String {
        "\(self.x.formatted(.number.precision(.significantDigits(digits)))), \(self.y.formatted(.number.precision(.significantDigits(digits))))"
    }
    
    func parenthesized(precision digits: Int = 6) -> String {
        "(" + self.commaed(precision: digits) + "),"
    }
}

extension Coordinate: Positionable {
    init(_ x: Float, _ y: Float) { self.init(x: x, y: y, z: 0) }
    func commaed(precision digits: Int = 6) -> String {
        "\(self.x.formatted(.number.precision(.significantDigits(digits)))), \(self.y.formatted(.number.precision(.significantDigits(digits)))), \(self.z.formatted(.number.precision(.significantDigits(digits))))"
    }
    
    func parenthesized(precision digits: Int = 6) -> String {
        "(" + self.commaed(precision: digits) + "),"
    }
}
