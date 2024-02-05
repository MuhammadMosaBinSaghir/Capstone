import MetalKit

struct Mesh: Transformable {
    @frozen enum Formats: String, CaseIterable { case msh, stl }
    
    var scale: Float = 1
    var position = Coordinate(x: 0, y: -0.25, z: 0)
    var rotation = Angle(.degrees, x: -45, y: -45, z: 0)
    
    var transform: Transform {
        .init(scale: scale, rotation: rotation, position: position)
    }
    
    /// The vertices derived from the volume's cross-section representation.
    let vertices: (elements: [Coordinate], buffer: MTLBuffer)
    /// The employed vertex structure
    /// - Note: No more then 65,535 vertices can make up a volume.
    /// - Note: There are `(6 - 6/section.loops.count)` times more indices than vertices.
    let indices: (elements: [UInt16], buffer: MTLBuffer)
    
    /// Initializes a volume from a cross-section
    /// - Warning: No more then 65,535 vertices can make up a volume.
    /// - Note: The number of vertices is equal to the product of the number of loops in a cross-section and the number of points per loop.
    init?(from section: CrossSection, to device: MTLDevice) {
        precondition((section.loops.count * section.loops[0].count) <= UInt16.max)
        let vertices = section.vertices()
        let indices = section.indices()
        guard let v = device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<Coordinate>.stride * vertices.count,
            options: .storageModeShared
        ) else { return nil }
        guard let i = device.makeBuffer(
            bytes: indices,
            length: MemoryLayout<UInt16>.size * indices.count,
            options: .storageModeShared
        ) else { return nil }
        self.vertices = (elements: vertices, buffer: v)
        self.indices = (elements: indices, buffer: i)
    }
}
