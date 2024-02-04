import Foundation

struct Angle: Hashable {
    let radians: Coordinate
    let degrees: Coordinate
    static let zero = Self(radians: .zero)
    private static let factor = 180/Float.pi
    
    @frozen enum Kind { case radians, degrees }
    
    init(radians: Coordinate) {
        self.radians = radians
        self.degrees = radians * Angle.factor
    }
    init(degrees: Coordinate) {
        self.degrees = degrees
        self.radians = degrees / Angle.factor
    }
    
    init(_ kind: Kind = .radians, x: Float = 0, y: Float = 0, z: Float = 0) {
        switch kind {
        case .degrees: self.init(degrees: Coordinate(x: x, y: y, z: z))
        case .radians: self.init(radians: Coordinate(x: x, y: y, z: z))
        }
    }
    
    func hash(into hasher: inout Hasher) { hasher.combine(radians) }
}
