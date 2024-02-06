import MetalKit

class Renderer: NSObject {
    var mesh: Mesh
    var uniforms = Uniforms()
    private var state: MTLRenderPipelineState
    private static var device: MTLDevice?
    private static var queue: MTLCommandQueue?
    private static var library: MTLLibrary?

    enum Errors: Error { case device, queue, mesh, library, pipeline, buffer }
    
    init?(from section: Model, to view: MTKView, refresh frames: UInt8) throws {
        guard let device = MTLCreateSystemDefaultDevice()
        else { throw Errors.device }
        guard let queue = device.makeCommandQueue()
        else { throw Errors.queue }
        
        guard let library = device.makeDefaultLibrary()
        else { throw Errors.library }
    
        let V = library.makeFunction(name: "vertexed")
        let F = library.makeFunction(name: "fragmented")
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = V
        descriptor.fragmentFunction = F
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        descriptor.vertexDescriptor = MTLVertexDescriptor.mesh
        
        guard let state = try? device.makeRenderPipelineState(descriptor: descriptor)
        else { throw Errors.pipeline }
        
        guard let mesh = Mesh(from: section, to: device)
        else { throw Renderer.Errors.mesh }
        
        Renderer.device = device
        Renderer.queue = queue
        Renderer.library = library
        
        self.mesh = mesh
        self.state = state
        self.uniforms.model = mesh.transform
        self.uniforms.view = Transform(translation: [0, 0, -1]).inverse
        
        super.init()
        view.device = device
        view.delegate = self
        view.layer?.isOpaque = false
        view.preferredFramesPerSecond = Int(frames)
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        uniforms.projection = Perspective(in: view.bounds.size, fov: Angle(.degrees, y: 90), planes: (near: 0.1, far: 100)).transform
    }

    func draw(in view: MTKView) {
        guard let commands = Renderer.queue?.makeCommandBuffer() else { return }
        guard let descriptor = view.currentRenderPassDescriptor else { return }
        guard let encoder = commands.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }
        
        encoder.setTriangleFillMode(.lines)
        encoder.setRenderPipelineState(state)
        encoder.setVertexBuffer(mesh.vertices.buffer, offset: 0, index: 0)
        encoder.setVertexBytes(
          &uniforms,
          length: MemoryLayout<Uniforms>.stride,
          index: 1
        )
        encoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: mesh.indices.elements.count,
            indexType: .uint16,
            indexBuffer: mesh.indices.buffer,
            indexBufferOffset: 0
        )
        encoder.endEncoding()
        
        guard let drawable = view.currentDrawable else { return }
        commands.present(drawable)
        commands.commit()
    }
}
