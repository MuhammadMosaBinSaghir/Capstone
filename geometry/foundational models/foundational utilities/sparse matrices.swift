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

struct SparseSolver {
    static func Laplacian(of unrolled: inout [Float], count: (long: Int, short: Int32), factorization: SparseOpaqueFactorization_Float) {
        let size = unrolled.count
        let solved = 
        [Float](unsafeUninitializedCapacity: 2 * count.long) { buffer, sized in
            unrolled.withUnsafeMutableBufferPointer { pointer in
                let P = DenseMatrix_Float(rowCount: count.short, columnCount: 2, columnStride: count.short, attributes: SparseAttributes_t(), data: pointer.baseAddress!)
                let Q = DenseMatrix_Float(rowCount: count.short, columnCount: 2, columnStride: count.short, attributes: SparseAttributes_t(), data: buffer.baseAddress!)
                SparseSolve(factorization, P, Q)
                sized = size
            }
        }
        unrolled = solved
    }
}
