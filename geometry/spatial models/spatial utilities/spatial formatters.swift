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

// make a giant array of text, reduce with \n
// Point form Loop -> "Point(\($0.offset + 1)) = { \(x), \(y), 0, 1 };\n"
// Add points for boundary
// Spline
// Lines, Line Loops, Surface, Transfinite, Mesh & convineice

// 
extension Loop {
    func mesh(radius: Float = 20, precision p: Int = 6) -> String {        
        var mesh = self.enumerated().map {
            let x = $0.element.x.formatted(.number.precision(.significantDigits(p)))
            let y = $0.element.y.formatted(.number.precision(.significantDigits(p)))
            return "Point(\($0.offset + 1)) = { \(x), \(y), 0, 1 };\n"
        }.reduce("") { $0 + $1 }
        mesh.append("Point(\(self.count + 1)) = { 1, \(radius), 0, 1 };\n")
        mesh.append("Point(\(self.count + 2)) = { 1, \(-radius), 0, 1 };\n")
        mesh.append(
            "Point(\(self.count + 3)) = { \(-radius + 1), 0, 0, 1 };\n"
        )
        mesh.append(
            "Point(\(self.count + 4)) = { \(radius), \(radius), 0, 1 };\n"
        )
        guard let last = self.last?.y.formatted(.number.precision(.significantDigits(p)))
        else { return "" }
        mesh.append(
            "Point(\(self.count + 5)) = { \(radius), \(last), 0, 1 };\n"
        )
        mesh.append(
            "Point(\(self.count + 6)) = { \(radius), \(-radius), 0, 1 };\n"
        )
        mesh.append(
            "Point(\(self.count + 7)) = { 1, 0, 0, 1 };\n"
        )
        mesh.append(
            "Point(\(self.count + 8)) = {-1E-6, 0, 1, 1.0};\n"
        )
        let l = leading[0]
        mesh.append("Spline(1) = { ")
        for i in 1...(l + 1) { mesh.append("\(i.formatted(.number.grouping(.never))), ") }
        mesh.removeLast(2)
        mesh.append(" };\nSpline(2) = { ")
        print(self.count)
        for j in (l + 1)...(self.count - 1) { mesh.append("\(j.formatted(.number.grouping(.never))), ") }
        mesh.append(" 1 };\n")
        mesh.append("Line(3) = {1, \(self.count + 1)};\n")
        mesh.append("Line(4) = {1, \(self.count + 2)};\n")
        mesh.append("Line(5) = {\(l + 1), \(self.count + 3)};\n")
        mesh.append(
            "Circle(6) = {\(self.count + 1), \(self.count + 7), \(self.count + 3)};\n"
        )
        mesh.append(
            "Circle(7) = {\(self.count + 3), \(self.count + 7), \(self.count + 2)};\n"
        )
        mesh.append("Line(8) = {1 , \(self.count + 5)};\n")
        mesh.append("Line(9) = {\(self.count + 1), \(self.count + 4)};\n")
        mesh.append("Line(10) = {\(self.count + 2), \(self.count + 6)};\n")
        mesh.append("Line(11) = {\(self.count + 5), \(self.count + 6)};\n")
        mesh.append("Line(12) = {\(self.count + 5), \(self.count + 4)};\n")
        mesh.append("Line Loop(13) = {3, 6, -5, -1};\n")
        mesh.append("Line Loop(14) = {2, 4, -7, -5};\n")
        mesh.append("Line Loop(15) = {4, 10, -11, -8};\n")
        mesh.append("Line Loop(16) = {8, 12, -9, -3};\n")
        mesh.append("Surface(1) = {13};\n")
        mesh.append("Surface(2) = {-14};\n")
        mesh.append("Surface(3) = {15};\n")
        mesh.append("Surface(4) = {16};\n")
        mesh.append("Transfinite Line {1} = 100 Using Bump 0.05; // Airfoil Upper\n")
        mesh.append("Transfinite Line {2} = 100 Using Bump 0.05; // Airfoil Lower\n")
        mesh.append("Transfinite Line {6} = 100 Using Progression 1; // Farfield Up\n")
        mesh.append("Transfinite Line {7} = 100 Using Progression 1; // Farfield Down\n")
        mesh.append("Transfinite Line {3,5,4} = 175 Using Progression 1.086; // Lines\n")
        mesh.append("Transfinite Line {12,11} = 175 Using Progression 1.086; // Wake Vertical\n")
        mesh.append("Transfinite Line {8} = 50 Using Progression 1.175; // Wake Horizontal\n")
        mesh.append("Transfinite Line {9,10} = 50 Using Progression 1.175; // Wake Offset Horizontal\n")
        mesh.append("Transfinite Surface {1};\n")
        mesh.append("Transfinite Surface {2};\n")
        mesh.append("Transfinite Surface {3};\n")
        mesh.append("Transfinite Surface {4};\n")
        mesh.append("Recombine Surface{1};\n")
        mesh.append("Recombine Surface{2};\n")
        mesh.append("Recombine Surface{3};\n")
        mesh.append("Recombine Surface{4};\n")
        mesh.append("Physical Curve(\"AIRFOIL\", 17) = {2, 1};\n")
        mesh.append("Physical Curve(\"FARFIELD\", 18) = {6, 7, 10, 11, 12, 9};\n")
        mesh.append("Physical Surface(\"MESH\", 19) = {1, 2, 3, 4};\n")
        mesh.append("Mesh 2;")
        return mesh
    }
}
