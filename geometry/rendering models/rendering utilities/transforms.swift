import simd
import Foundation

typealias Transform = float4x4

extension Transform {
    static let identity = matrix_identity_float4x4
    
    init(scale: Float) {
        self = .identity
        columns.3.w = 1/scale
    }
    
    init(scaling s: Coordinate) {
        self.init(
            [s.x, 0, 0, 0],
            [0, s.y, 0, 0],
            [0, 0, s.z, 0],
            [0, 0, 0, 1]
        )
    }
    
    init(translation t: Coordinate) {
        self.init(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [t.x, t.y, t.z, 1]
        )
    }
    
    init(rotation radians: Float, axis: Coordinate.Axis) {
        self = switch axis {
        case .abscissas:
            Transform(
              [1, 0, 0, 0],
              [0, cos(radians), sin(radians), 0],
              [0, -sin(radians), cos(radians), 0],
              [0, 0, 0, 1]
            )
        case .ordinates:
            Transform(
                [cos(radians), 0, -sin(radians), 0],
                [0, 1, 0, 0],
                [sin(radians), 0, cos(radians), 0],
                [0, 0, 0, 1]
            )
        case .applicates:
            Transform(
                [ cos(radians), sin(radians), 0, 0],
                [-sin(radians), cos(radians), 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]
            )
        }
    }
    
    init(rotation angle: Angle) {
        let x = Transform(rotation: angle.radians.x, axis: .abscissas)
        let y = Transform(rotation: angle.radians.y, axis: .ordinates)
        let z = Transform(rotation: angle.radians.z, axis: .applicates)
        self = x * y * z
    }
    
    init(scale: Float, rotation: Angle, position: Coordinate) {
      let translation = Transform(translation: position)
      let rotation = Transform(rotation: rotation)
      let scale = Transform(scale: scale)
      self = translation * rotation * scale
    }
}
