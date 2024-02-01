import Accelerate

enum SparseMatrixKind: RawRepresentable {
    case ordinary, symmetric, triangular
    
    init?(rawValue: SparseKind_t) {
        switch rawValue {
        case SparseOrdinary: self = .ordinary
        case SparseSymmetric: self = .symmetric
        case SparseTriangular: self = .triangular
        default: return nil
        }
    }

    var rawValue: SparseKind_t {
        switch self {
        case .ordinary: return SparseOrdinary
        case .symmetric: return SparseSymmetric
        case .triangular: return SparseTriangular
        }
    }
}

enum SparseMatrixTriangleType: RawRepresentable {
    case lowersided, upperside
    
    init?(rawValue: SparseTriangle_t) {
        switch rawValue {
        case SparseLowerTriangle: self = .lowersided
        case SparseUpperTriangle: self = .upperside
        default: return nil
        }
    }

    var rawValue: SparseTriangle_t {
        switch self {
        case .lowersided: return SparseLowerTriangle
        case .upperside: return SparseUpperTriangle
        }
    }
}

extension SparseAttributes_t {
    init(kind: SparseMatrixKind, sidedness: SparseMatrixTriangleType, transposed: Bool = false, preallocated: Bool = false, reserve: UInt32 = 0) {
        self.init(transpose: transposed, triangle: sidedness.rawValue, kind: kind.rawValue, _reserved: reserve, _allocatedBySparse: preallocated)
    }
}

extension SparseOpaqueFactorization_Float {
    static func Laplacian(factor λ: Float, size: Int) -> Self {
        let side = -λ/2
        let diagonal = 1 + λ
        let count = (long: size, short: Int32(size))
        let edge = (long: count.long - 1, short: count.short - 1)
        let inners = 0...(edge.short - 2)
        var columns = stride(from: 0, through: 3 * count.long, by: 3).map { $0 }
        var rows = inners.reduce([0, 1, edge.short]) {
            $0 + [$1, $1 + 1, $1 + 2]
        } + [0, edge.short - 1, edge.short]
        let attributes = SparseAttributes_t(kind: .symmetric, sidedness: .lowersided)
        let structure = rows.withUnsafeMutableBufferPointer { r in
            columns.withUnsafeMutableBufferPointer { c in
                SparseMatrixStructure(rowCount: count.short, columnCount: count.short, columnStarts: c.baseAddress!, rowIndices: r.baseAddress!, attributes: attributes, blockSize: 1)
            }
        }
        var contents = (1...(edge.long - 1)).reduce([diagonal, side, side]) { c, _ in
            c + [side, diagonal, side]
        } + [side, side, diagonal]
        
         return contents.withUnsafeMutableBufferPointer {
            let Laplacian =
            SparseMatrix_Float(structure: structure, data: $0.baseAddress!)
            return SparseFactor(SparseFactorizationCholesky, Laplacian)
        }
    }
}

func smoothen<P: Positionable>(_ points: Array<P>, λ: Double, I: Int) -> [Point] {
    let side = -λ/2
    let diagonal = 1 + λ
    let edge = points.count - 1
    let edge32 = Int32(edge)
    let count32 = Int32(points.count)
    let inners: ClosedRange<Int32> = 0...(edge32 - 2)
    
    var columns: [Int] = stride(from: 0, through: 3 * points.count, by: 3).map { $0 }
    var rows: [Int32] = inners.reduce([0, 1, edge32]) { $0 + [$1, $1 + 1, $1 + 2] }
    var contents: [Double] = (1...(edge - 1)).reduce([diagonal, side, side]) { c, _ in
        c + [side, diagonal, side]
    }
    rows += [0, edge32 - 1, edge32]
    contents += [side, side, diagonal]
    
    let attributes = SparseAttributes_t(transpose: false, triangle: SparseLowerTriangle, kind: SparseSymmetric, _reserved: 0, _allocatedBySparse: false)
    
    let structure: SparseMatrixStructure = rows.withUnsafeMutableBufferPointer { r in
        columns.withUnsafeMutableBufferPointer { c in
            SparseMatrixStructure(rowCount: count32, columnCount: count32, columnStarts: c.baseAddress!, rowIndices: r.baseAddress!, attributes: attributes, blockSize: 1)
        }
    }
    
    let factorized: SparseOpaqueFactorization_Double = contents.withUnsafeMutableBufferPointer {
        let Laplacian = SparseMatrix_Double(structure: structure, data: $0.baseAddress!)
        return SparseFactor(SparseFactorizationCholesky, Laplacian)
    }
    
    var X = points.map { Double($0.x) }
    var Y = points.map { Double($0.y) }
    var U = Array(repeating: Double.zero, count: points.count)
    var V = Array(repeating: Double.zero, count: points.count)
    
    var b = points.map {  Double($0.x) }
    b += points.map { Double($0.y) }
    //defer {
        //SparseCleanup(A)
        //SparseCleanup(factorization)
    //}
    let n = b.count

    for _ in 1...I {
        let xValues = [Double](unsafeUninitializedCapacity: n) {
            buffer, count in
            b.withUnsafeMutableBufferPointer { bPtr in
                let B = DenseMatrix_Double(rowCount: Int32(points.count),
                                           columnCount: 2,
                                           columnStride: Int32(points.count),
                                           attributes: SparseAttributes_t(),
                                           data: bPtr.baseAddress!)
                
                let Xnew = DenseMatrix_Double(rowCount: Int32(points.count),
                                              columnCount: 2,
                                              columnStride: Int32(points.count),
                                              attributes: SparseAttributes_t(),
                                              data: buffer.baseAddress!)
                
                SparseSolve(factorized, B, Xnew)
                count = n
            }
        }
        b = xValues
    }
    
    //
    return points.indices.map { Point(x: Float(b[$0]), y: Float(b[points.count + $0])) }
        
    for _ in 1...I {
        X.withUnsafeMutableBufferPointer { xp in
            U.withUnsafeMutableBufferPointer { up in
                let x = DenseVector_Double(count: count32, data: xp.baseAddress!)
                let u = DenseVector_Double(count: count32, data: up.baseAddress!)
                SparseSolve(factorized, x, u)
            }
        }
        Y.withUnsafeMutableBufferPointer { yp in
            V.withUnsafeMutableBufferPointer { vp in
                let y = DenseVector_Double(count: count32, data: yp.baseAddress!)
                let v = DenseVector_Double(count: count32, data: vp.baseAddress!)
                SparseSolve(factorized, y, v)
            }
        }
        X = U
        Y = V
        U = Array(repeating: Double.zero, count: points.count)
        V = Array(repeating: Double.zero, count: points.count)
    }
    
    return zip(X, Y).map { Point(x: Float($0), y: Float($1)) }
}
