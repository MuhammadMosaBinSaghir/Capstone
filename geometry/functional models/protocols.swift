import SwiftUI

protocol Exponentiable: FloatingPoint {
    static var e: Self { get }
    static func ** (_ lhs: Self, _ rhs: Self) -> Self
    static prefix func √ (_ radicand: Self) -> Self
}

protocol Positionable {
    var x: Float { get set }
    var y: Float { get set }
    init(_ x: Float, _ y: Float)
    func text(precision digits: Int) -> String
}

protocol SpatialCollection: BidirectionalCollection
where Element: Positionable, Index == Int {
    func path(in rect: CGRect) -> Path
    func text(precision digits: Int) -> String
    func convolve(with kernel: Kernel) -> Self?
}

protocol OrderedCollection: BidirectionalCollection where Index == Int {
    associatedtype Element
    func emptied() -> Self
    func inversed() -> Self
}
