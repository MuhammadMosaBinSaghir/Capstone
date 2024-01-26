import Foundation

struct Angle: Comparable, Hashable {
    let radians: Float
    let degrees: Float
    private static let factor = 180/Float.pi
    
    init(radians: Float) {
        self.radians = radians
        self.degrees = radians * Angle.factor
    }
    init(degrees: Float) {
        self.degrees = degrees
        self.radians = degrees / Angle.factor
    }
    
    static func < (lhs: Angle, rhs: Angle) -> Bool {
        lhs.radians < rhs.radians
    }
    
    func hash(into hasher: inout Hasher) { hasher.combine(radians) }
}
