import Foundation

extension CGFloat {
    func vectored() -> Float { Float(self) }
}

extension CGPoint {
    init(_ point: Point) { self.init(x: Double(point.x), y: Double(point.y)) }
    func vectored() -> Point { Point(x: self.x.vectored(), y: self.y.vectored()) }
}
