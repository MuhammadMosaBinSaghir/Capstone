import Foundation
import MetalKit
typealias Point = simd_float2

extension Point {
    func magnitude() -> Float { length(self) }
    func dot(_ pointed: Self) -> Angle {
        let normal = simd.dot(self, pointed) / (self.magnitude() * pointed.magnitude())
        let clamped = normal.clamped(to: -1...1)
        return Angle(radians: acos(clamped))
    }
    func dot(_ pointed: Self, from origin: Self) -> Angle {
        (self - origin).dot(pointed - origin)
    }
    func distance(to pointed: Self) -> Float {
        sqrt(pow(pointed.x - self.x, 2) + pow(pointed.y - self.y, 2))
    }
    
    func knot(from base: Float, to pointed: Point, type: Spline) -> Float {
        pow(self.distance(to: pointed), type.alpha()) + base
    }
}
