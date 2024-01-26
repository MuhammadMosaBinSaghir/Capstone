import Foundation

protocol SpatialCollection: BidirectionalCollection
where Element == Point, Index == Int {
    init?(_ text: String)
    func text(precision digits: Int) -> String
}

protocol OrderedCollection: BidirectionalCollection where Index == Int {
    associatedtype Element
    func emptied() -> Self
    func inversed() -> Self
}
