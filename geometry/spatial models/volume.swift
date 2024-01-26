import Foundation
import OrderedCollections

/// An approximation of a three-dimensional volume constructed by taking slices of an underlying shape.
///
/// Volumes are made up of loops and the unique planes on which said loops lie. Interpolation in between loops allows for a the creation of a blended volume.
///
/// - Note: Volumes are defined by at least 1 loop-plane pair.
struct Volume {
    let label: String
    /// The defining loops sorted based on the planes on which they lie.
    ///
    /// Loops are discrete 2-dimensional closed curves which are all assumed to exist in same coordinate-space.
    /// - Note: Interpolation requires that loops all contain the same number of points.
    let loops: [Loop]
    /// The planes on which a volume's loops lie.
    ///
    /// Planes are unique 1-dimensional positions that are located on an axis perpendicular to the loops' shared coordinate-space.
    /// - Note: Volumes are normalized to ensure that all planes fall within the range [0, 1].
    let planes: OrderedSet<Float>
    
    /// Conditionally initializes a volume from ordered loops and planes.
    /// - Note: Volumes are defined by at least 1 loop-plane pair and contain the same number of loops as planes.
    init?(_ label: String, with loops: [Loop], at planes: OrderedSet<Float>) {
        self.label = label
        guard let decimated = loops.decimated(with: planes) else { return nil }
        let (planes, loops) = decimated.attributes.normalized(with: decimated.loops)
        self.loops = loops
        self.planes = OrderedSet(planes)
    }
}
