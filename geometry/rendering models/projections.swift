import Foundation

struct Perspective: Projection {
    let view: Float
    let aspect: Float
    let handedness: Handedness
    let planes: (near: Float, far: Float)
    @frozen enum Handedness { case left, right }
    
    init(in size: CGSize, fov: Angle, planes: (near: Float, far: Float), handedness: Handedness = .left) {
        precondition(!planes.near.isZero)
        self.planes = planes
        self.view = fov.radians.y
        self.handedness = handedness
        self.aspect = (size.width/size.height).ungraphed()
    }
    
    var transform: Transform {
        let x = 1 / (aspect * tan(0.5 * view))
        let y = x * aspect
        let z = switch handedness {
        case .left: planes.far / (planes.far - planes.near)
        case .right: planes.far / (planes.near - planes.far)
        }
        return switch handedness {
        case .left:
            Transform(
                [x, 0, 0, 0],
                [0, y, 0, 0],
                [0, 0, z, 1],
                [0, 0, planes.near * -z, 0]
            )
        case .right:
            Transform(
                [x, 0, 0, 0],
                [0, y, 0, 0],
                [0, 0, z, -1],
                [0, 0, planes.near * z, 0]
            )
        }
    }
}
