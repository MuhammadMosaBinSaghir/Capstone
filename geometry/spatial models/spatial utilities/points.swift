import simd
import Foundation

typealias Point = simd_float2

extension Point {
    func magnitude() -> Float { length(self) }
    func distance(to pointed: Self) -> Float { simd.distance(self, pointed) }
    func cross(_ pointed: Self) -> Float { simd.cross(self, pointed).z }
    func cross(to pointed: Self, from origin: Self) -> Float {
        (self - pointed).cross(origin - pointed)
    }
    func area(to pointed: Self, from origin: Self) -> Loop.Area {
        Loop.Area(0.5 * self.cross(to: pointed, from: origin))
    }
    func graphed() -> CGPoint { CGPoint(self) }
    func projected(onto plane: Float) -> Coordinate {
        Coordinate(self.x, self.y, plane)
    }
}
