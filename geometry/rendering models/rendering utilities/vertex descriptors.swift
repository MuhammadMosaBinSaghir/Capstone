import MetalKit

extension MTLVertexDescriptor {
    static let mesh = meshed()
    
    private static func meshed() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        descriptor.attributes[0].offset = 0
        descriptor.attributes[0].bufferIndex = 0
        descriptor.attributes[0].format = .float3
        descriptor.layouts[0].stride = MemoryLayout<Coordinate>.stride
        return descriptor
    }
}
