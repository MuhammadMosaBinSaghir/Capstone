import Foundation

struct Kernel {
    typealias Index = Array<Any>.Index
    enum Types { case box, triangle, gaussian(σ: Float) }
    
    var type: Types
    var count: Index
    var window: [Float] {
        switch type {
        case .box: return boxed()
        case .triangle: return triangular()
        case .gaussian(σ: let σ): return gaussian(σ: σ)
        }
    }
    
    private var length: Float { Float(count - 1) }
    private var μ: Float { 0.5*length }
    
    func boxed() -> [Float] {
        guard count >= 1 else { return [] }
        return Array(repeating: 1 / Float(count), count: count)
    }
    
    func triangular() -> [Float] {
        guard count >= 2 else { return [] }
        return (0..<count).map { 1 - abs(Float($0) - μ)/μ }
    }
    
    func gaussian(σ: Float) -> [Float] {
        guard count >= 2 else { return [] }
        let samples = stride(from: μ - 3*σ, through: μ + 3*σ, by: 6*σ/length)
        return samples.map { Float.Ν(x: $0, μ: μ, σ: σ) }
    }
}
