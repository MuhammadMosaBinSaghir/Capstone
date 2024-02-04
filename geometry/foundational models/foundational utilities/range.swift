import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(limits.lowerBound, self), limits.upperBound)
    }
}

extension ClosedRange where Bound: Numeric  {
    var magnitude: Bound { self.upperBound - self.lowerBound }
}
