import Foundation
import OrderedCollections

extension [Point].Formatter where Output == [Coordinate] {
    static var coordinates: Self { .init {
        $0.map { $0.projected(onto: .zero) }
    } }
}

extension Array.Formatter where Element: Positionable, Output == String {
    static var txt: Self { .init { $0.formatted(.txt(precision: 6)) } }
    
    static func txt(precision digits: Int) -> [Element].Formatter<String> {
        Self.init {
            let components = $0.map { $0.parenthesized(precision: digits) }
            var text = components.reduce("[") { $0 + $1 }
            text.removeLast()
            text.append("]")
            return text
        }
    }
}

extension Array.Formatter where Element: Positionable, Output == [Element] {
    static func scaled(by measurement: Measurement<UnitLength>, into units: UnitLength? = nil) -> [Element].Formatter<[Element]> {
        Self.init {
            let desired = units ?? measurement.unit
            let factor = Float(measurement.converted(to: desired).value)
            return $0.map { factor * $0 }
        }
    }
}


extension OrderedSet.Formatter where Element: Positionable, Output == String {
    static var txt: Self { .init { $0.formatted(.txt(precision: 6)) } }
    
    static func txt(precision digits: Int) -> OrderedSet<Element>.Formatter<String> {
        Self.init { $0.elements.formatted(.txt(precision: digits))
        }
    }
}

extension Loop.Formatter where Output == [Coordinate] {
    static var clockwise: Self { .init {
        $0.clockwised().formatted(.coordinates)
    } }
    
    static var headfirst: Self { .init {
        $0.headfirst().formatted(.coordinates)
    } }
    
    static func inversed(close: Bool = false) -> Loop.Formatter<[Coordinate]> {
        close ?
        Self.init { loop in
            loop.headfirst().inversed(close: true).formatted(.coordinates)
        } :
        Self.init { loop in
            loop.headfirst().inversed().formatted(.coordinates)
        }
    }
}

extension Loop.Formatter where Output == String {
    static var txt: Self { .init { $0.formatted(.txt(precision: 6)) } }
    
    static func txt(precision digits: Int) -> Loop.Formatter<String> {
        Self.init { $0.points.elements.formatted(.txt(precision: digits)) }
    }
    
    static func csv(precision digits: Int, scale: Measurement<UnitLength> = Measurement(value: 1, unit: .meters), units: UnitLength? = nil) -> Loop.Formatter<String> {
        Self.init {
            let coordinates = $0.formatted(.inversed(close: true))
            let scaled = coordinates.formatted(.scaled(by: scale, into: units))
            let components = scaled.map { $0.commaed(precision: digits) }
            var text = components.reduce("") { $0 + ($1 + "\n") }
            text.removeLast()
            return text
        }
    }
}
