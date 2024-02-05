import Foundation

protocol Exponentiable: FloatingPoint {
    static var e: Self { get }
    static func ** (_ lhs: Self, _ rhs: Self) -> Self
    static prefix func √ (_ radicand: Self) -> Self
}

protocol Positionable {
    var x: Float { get set }
    var y: Float { get set }
    init(_ x: Float, _ y: Float)
    static var zero: Self { get }
    func text(precision digits: Int) -> String
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Float, rhs: Self) -> Self
    static func / (lhs: Self, rhs: Float) -> Self
}

protocol Projection { var transform: Transform { get } }

protocol Transformable {
    var scale: Float { get set }
    var rotation: Angle { get set }
    var position: Coordinate { get set }
    var transform: Transform { get }
}

protocol SpatialCollection: BidirectionalCollection
where Element: Positionable, Index == Int {
    func smoothen(by λ: Float) -> [Element]
    func text(precision digits: Int) -> String
}

protocol OrderedCollection: BidirectionalCollection where Index == Int {
    associatedtype Element
    func emptied() -> Self
    func inversed() -> Self
}