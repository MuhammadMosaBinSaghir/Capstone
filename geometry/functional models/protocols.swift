import SwiftUI

protocol Positionable {
    var x: Float { get set }
    var y: Float { get set }
    func text(precision digits: Int) -> String
}

protocol SpatialCollection: BidirectionalCollection
where Element: Positionable, Index == Int {
    func path(in rect: CGRect) -> Path
    func text(precision digits: Int) -> String
}

protocol OrderedCollection: BidirectionalCollection where Index == Int {
    associatedtype Element
    func emptied() -> Self
    func inversed() -> Self
}
