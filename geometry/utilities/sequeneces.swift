import Foundation

extension Sequence {
    func sorted<T: Comparable>(by path: KeyPath<Element, T>, using comparator: (T, T) -> Bool = (<)) -> [Element] {
        sorted { comparator($0[keyPath: path], $1[keyPath: path]) }
    }
}
