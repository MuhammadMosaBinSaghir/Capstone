import Foundation

extension CGFloat {
    func ungraphed() -> Float { Float(self) }
}

extension CGPoint {
    init(_ point: Point) { self.init(x: Double(point.x), y: Double(point.y)) }
    func vectored() -> Point { Point(x: self.x.ungraphed(), y: self.y.ungraphed()) }
}
