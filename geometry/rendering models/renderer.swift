import MetalKit

class Renderer: NSObject {
    var mesh: Mesh
    var state: MTLRenderPipelineState
    static var device: MTLDevice?
    static var queue: MTLCommandQueue?
    static var library: MTLLibrary?
    
    enum Errors: Error { case device, queue, mesh, library, pipeline, buffer }
    
    init?(from section: CrossSection, to view: MTKView) throws {
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
        
        self.mesh = mesh
        self.state = state
        Renderer.device = device
        Renderer.queue = queue
        Renderer.library = library
        
        super.init()
        view.device = device
        view.delegate = self
        view.layer?.isOpaque = false
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
}
