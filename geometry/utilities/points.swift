import Foundation
import MetalKit
typealias Point = simd_float2

extension Point {
    func magnitude() -> Float { length(self) }
    func distance(to pointed: Self) -> Float { simd.distance(self, pointed) }
    func cross(_ pointed: Self) -> Float { simd.cross(self, pointed).z }
    func dot(_ pointed: Self) -> Angle {
        let normal = simd.dot(self, pointed) / (self.magnitude() * pointed.magnitude())
        let clamped = normal.clamped(to: -1...1)
        return Angle(radians: acos(clamped))
    }
    func cross(to pointed: Self, from origin: Self) -> Float {
        (self - pointed).cross(origin - pointed)
    }
    func dot(_ pointed: Self, from origin: Self) -> Angle {
        (self - origin).dot(pointed - origin)
    }
    func area(to pointed: Self, from origin: Self) -> Loop.Area {
        Loop.Area(0.5 * self.cross(to: pointed, from: origin))
    }
}
