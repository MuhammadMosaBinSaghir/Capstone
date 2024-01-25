import Foundation
import OrderedCollections

enum Spline: String, CaseIterable {
    case centripetal, chordal, uniform
    func alpha() -> Float {
        switch self {
        case .centripetal: return 0.5
        case .chordal: return 1
        case .uniform: return 0
        }
    }
}

extension [Point] {
    func spline(_ type: Spline = .centripetal, by accuracy: Int = 4) -> Self {        guard accuracy > 0 else { return self }
        guard self.count > 3 else { return self }
        var spline = [Point]()
        for i in 0...self.count - 2 {
            let P0 = self[i == 0 ? self.count - 3 : i - 1]
            let P1 = self[i]
            let P2 = self[i+1]
            let P3 = self[i == (self.count - 2) ? 1 : i + 2]
            
            let t0: Float = 0.0
            let t1 = P0.knot(from: t0, to: P1, type: type)
            let t2 = P1.knot(from: t1, to: P2, type: type)
            let t3 = P2.knot(from: t2, to: P3, type: type)
            
            let step = (t2 - t1) / Float(accuracy + 1)
            
            for t in stride(from: t1, to: t2, by: step) {
                let A1 = (t1 - t) / (t1 - t0) * P0 + (t - t0) / (t1 - t0) * P1
                let A2 = (t2 - t) / (t2 - t1) * P1 + (t - t1) / (t2 - t1) * P2
                let A3 = (t3 - t) / (t3 - t2) * P2 + (t - t2) / (t3 - t2) * P3
                let B1 = (t2 - t) / (t2 - t0) * A1 + (t - t0) / (t2 - t0) * A2
                let B2 = (t3 - t) / (t3 - t1) * A2 + (t - t1) / (t3 - t1) * A3
                let point = (t2 - t) / (t2 - t1) * B1 + (t - t1) / (t2 - t1) * B2
                spline.append(point)
            }
        }
        spline.append(self.last!)
        return spline
    }
    
    func mesh(radius: Float = 20, precision p: Int = 6) -> String {
        let A = Loop(Library.middle)!
        let B = Loop(Library.wingtip)!
        let C = Loop(Library.third)!
        let D = Loop(Library.base)!
        
        let loops = OrderedSet([A, B, D])
 
        let planes = OrderedSet<Float>([50, 100, 0])
        let wing = Wing("", with: loops, at: planes)

        
        let sorted = self.sorted { $0.x < $1.x }
        guard let leading = sorted.first else { return "" }
        guard let trailing = sorted.last else { return "" }
        let chord = trailing.x - leading.x
        let scaled = self.map {
            Point(
                x: ($0.x - leading.x)/chord,
                y: ($0.y - leading.y)/chord
            )
        }
        
        var mesh = scaled.enumerated().map {
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
        guard let last = scaled.last?.y.formatted(.number.precision(.significantDigits(p))) 
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
        guard let l = self.firstIndex(of: leading) else { return "" }
        mesh.append("Spline(1) = { ")
        for i in 1...(l + 1) { mesh.append("\(i.formatted(.number.grouping(.never))), ") }
        mesh.removeLast(2)
        mesh.append(" };\nSpline(2) = { ")
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
        mesh.append("Transfinite Line {1} = 100 Using Bump 1; // Airfoil Upper\n")
        mesh.append("Transfinite Line {2} = 100 Using Bump 1; // Airfoil Lower\n")
        mesh.append("Transfinite Line {6} = 100 Using Progression 1; // Farfield Up\n")
        mesh.append("Transfinite Line {7} = 100 Using Progression 1; // Farfield Down\n")
        mesh.append("Transfinite Line {3,5,4} = 100 Using Progression 1; // Lines\n")
        mesh.append("Transfinite Line {12,11} = 100 Using Progression 1; // Wake Vertical\n")
        mesh.append("Transfinite Line {8} = 50 Using Progression 1; // Wake Horizontal\n")
        mesh.append("Transfinite Line {9,10} = 50 Using Progression 1; // Wake Offset Horizontal\n")
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

