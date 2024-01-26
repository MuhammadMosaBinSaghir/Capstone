import Foundation
import DequeModule

extension Collection where Element: Collection, Index == Int, Element.Index == Int {
    func isJagged() -> (Bool, mininumCount: Element.Index?, maximumCount: Element.Index?) {
        guard !self.isEmpty else { return (true, mininumCount: nil, maximumCount: nil) }
        guard self.count > 1 else {
            return (true, mininumCount: self[0].count, maximumCount: self[0].count)
        }
        var deque = Deque([self[0].count])
        (1..<self.endIndex).forEach {
            let count = self[$0].count
            switch count {
            case _ where count < deque.first!: deque.prepend(count)
            case _ where count > deque.last!: deque.append(count)
            default: return
            }
        }
        return (deque.count > 1, mininumCount: deque.first, maximumCount: deque.last)
    }
}

extension Collection where Element == Loop, Index == Int {
    func decimated<C: Collection>(with attributes: C) -> (loops: [Element], attributes: [C.Element])? where C.Index == Int {
        guard !self.isEmpty && self.count == attributes.count else { return nil }
        let (jagged, minimum, _) = self.isJagged()
        guard let downsized = minimum else { return nil }
        guard jagged
        else { return (Array(self), Array(attributes)) }
        let zipped = zip(self, attributes).compactMap { (loop, plane) in
            let count = loop.count
            guard count != minimum else { return (loop, plane) }
            guard let decimated = loop.decimated(removing: count - downsized)
            else { return nil }
            return (decimated, plane)
        }
        guard !zipped.isEmpty else { return nil }
        return (zipped.map { $0.0 }, zipped.map { $0.1 })
    }
}

extension Collection where Element: FloatingPoint, Index == Int {
    func normalized<C: Collection>(with attributes: C) -> (elements: [Element], attributes: [C.Element]) where C.Index == Int {
        guard !self.isEmpty && self.count == attributes.count else {
            return (elements: [], attributes: [])
        }
        guard self.count > 1 else {
            return (elements: Array(self), attributes: Array(attributes))
        }
        let offsets = self.enumerated().sorted { $0.element < $1.element }
        let sorted = offsets.map { $0.element }
        let first = sorted.first!, last = sorted.last!
        guard first != last else { return (elements: [], attributes: []) }
        let length = last - first
        let normalized = sorted.map { ($0 - first)/length }
        let attributes = offsets.map { attributes[$0.offset] }
        return (elements: normalized, attributes: attributes)
    }
}
