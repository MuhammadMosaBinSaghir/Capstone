import Foundation
import MetalKit

typealias Coordinate = simd_float3

extension Coordinate {
    @frozen enum Axis { case abscissas, ordinates, applicates }
    static func located(between pointer: Self, and pointed: Self, at location: Float, on axis: Axis = .applicates) -> Self {
        let gradient = pointed - pointer
        let parameter = switch axis {
        case .abscissas: (location - pointer.x)/gradient.x
        case .ordinates: (location - pointer.y)/gradient.y
        case .applicates: (location - pointer.z)/gradient.z
        }
        return pointer + gradient * parameter
    }
    func flat() -> Point { Point(self.x, self.y) }
}
