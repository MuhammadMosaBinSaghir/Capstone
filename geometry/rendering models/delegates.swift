import MetalKit

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }

    func draw(in view: MTKView) {
        guard let commands = Renderer.queue?.makeCommandBuffer() else { return }
        guard let descriptor = view.currentRenderPassDescriptor else { return }
        guard let encoder = commands.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }
        
        encoder.setTriangleFillMode(.lines)
        encoder.setRenderPipelineState(state)
        encoder.setVertexBuffer(mesh.vertices.buffer, offset: 0, index: 0)
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
