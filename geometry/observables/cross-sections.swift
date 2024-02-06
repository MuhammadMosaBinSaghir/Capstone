import Foundation

@Observable class CrossSections: Equatable {
    var amount: Int
    var region: ClosedRange<Float>
    var selected: [Float] {
        let distance = region.upperBound - region.lowerBound
        guard amount >= 2 else { return [0.5*distance + region.lowerBound] }
        return stride(
            from: region.lowerBound,
            through: region.upperBound,
            by: distance/Float(amount - 1)
        ).map { $0 }
    }
    
    static func == (lhs: CrossSections, rhs: CrossSections) -> Bool {
        lhs.amount == rhs.amount && lhs.region == rhs.region
    }
    
    init(in region: ClosedRange<Float>, select amount: Int) {
        self.amount = amount
        self.region = region
    }
}
