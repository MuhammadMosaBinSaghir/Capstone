import Foundation

extension Point: Positionable {
    func text(precision digits: Int = 6) -> String {
        "(\(self.x.formatted(.number.precision(.significantDigits(digits)))), \(self.y.formatted(.number.precision(.significantDigits(digits))))),"
    }
}
extension Coordinate: Positionable {
    func text(precision digits: Int = 6) -> String {
        "(\(self.x.formatted(.number.precision(.significantDigits(digits)))), \(self.y.formatted(.number.precision(.significantDigits(digits)))), \(self.z.formatted(.number.precision(.significantDigits(digits))))),"
    }
}
