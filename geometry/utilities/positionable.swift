import Foundation

extension Point: Positionable {
    func text(precision digits: Int = 6) -> String {
        "(\(self.x.formatted(.number.precision(.significantDigits(digits)))), \(self.y.formatted(.number.precision(.significantDigits(digits))))),"
    }
}
extension Coordinate: Positionable {
    init(_ x: Float, _ y: Float) { self.init(x: x, y: y, z: 0) }
    func text(precision digits: Int = 6) -> String {
        "(\(self.x.formatted(.number.precision(.significantDigits(digits)))), \(self.y.formatted(.number.precision(.significantDigits(digits)))), \(self.z.formatted(.number.precision(.significantDigits(digits))))),"
    }
}
