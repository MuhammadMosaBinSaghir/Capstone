import Foundation
import DequeModule

extension Collection where Element: FloatingPoint, Index == Int {
    func normalized<T: Collection>(with attributes: T) -> (elements: [Element], attributes: [T.Element]) where T.Index == Int {
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
        return (deque.count < 2, mininumCount: deque.first, maximumCount: deque.last)
    }
}
