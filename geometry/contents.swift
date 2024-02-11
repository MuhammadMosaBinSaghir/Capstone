import SwiftUI

struct Contents: View {
    @Environment(\.settings) private var settings
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Volume(from: settings.model)
            CrossSectionSelector(settings.sections)
                .frame(height: 32)
        }
        .toolbar { Toolbar() }
        .padding(8)
        .transparent()
        .ignoresSafeArea()
        .toolbarBackground(.clear, for: .windowToolbar)
        .onAppear {
            let smoo2: [Float] = [0.12626262, 1.2007576, 0.9980614, 0.5555556, 0.49658197]
            let loops = replicated.map { Loop($0) }
            let smoothed: [Loop] = loops.indices.map {
                Loop(loops[$0].smoothen(by: smoo2[$0]))
            }
            let wiggled = smoothed.map { old in
                var hull = Hull(old.points.elements)
                hull.quickHull()
                let new = Set(hull.convexHull)
                let wiggled = wiggleOut(from: old.points.elements, given: new, keep: 20)
                return Loop(wiggled)
            }
            let model = Model("wing", with: wiggled, at: [0, 0.25, 0.5, 0.75, 1])!
            
            let l = model.loops[0]
            let densities = (l.startIndex...(l.endIndex - 1)).map {
                2/l[$0].distance(to: l[$0 + 1])
            }
            guard let max = densities.max() else { return }
            let pointsToAdd = densities.map { floor(2/$0 * max) - 1 }
            let new: [[Point]?] = l.indices.map {
                let n = pointsToAdd[$0]
                guard n > 2 else { return nil }
                let elements = stride(from: 1, through: n - 2, by: 1).map { $0 }
                let percent = elements.map { $0 / (n - 1) }
                let p1 = l[$0]
                let p2 = l[$0 + 1]
                let p = percent.map { ($0 * p2) + ((1 - $0) * p1) }
                return p
            }
            let indices = l.indices.map { $0 }
            let evened = indices.reduce(into: [Point]()) {
                $0.append(l[$1])
                guard let p = new[$1] else { return }
                $0.append(contentsOf: p)
            }
            print(evened.formatted(.txt))
        }
    }
}

struct Toolbar: View {
    var body: some View {
        Spacer()
        DocumentSelector()
            .padding(.trailing, -3)
    }
}

/*
 let smoo2: [Float] = [0.12626262, 1.2007576, 0.9980614, 0.5555556, 0.49658197]
 let loops = replicated.map { Loop($0) }
 let smoothed: [Loop] = loops.indices.map {
     Loop(loops[$0].smoothen(by: smoo2[$0]))
 }
 let wiggled = smoothed.map { old in
     var hull = Hull(old.points.elements)
     hull.quickHull()
     let new = Set(hull.convexHull)
     let wiggled = wiggleOut(from: old.points.elements, given: new, keep: 20)
     return Loop(wiggled)
 }
 let model = Model("wing", with: wiggled, at: [0, 0.25, 0.5, 0.75, 1])!
 
 let l = model.loops[0]
 //print(l.formatted(.txt))
 let densities = (l.startIndex...(l.endIndex - 1)).map {
     2/l[$0].distance(to: l[$0 + 1])
 }
 guard let max = densities.max() else { return }
 let pointsToAdd = densities.map { floor(2/$0 * max) - 1 }
 let new: [[Point]?] = l.indices.map {
     let n = pointsToAdd[$0]
     guard n > 2 else { return nil }
     let elements = stride(from: 1, through: n - 2, by: 1).map { $0 }
     let percent = elements.map { $0 / (n - 1) }
     let p1 = l[$0]
     let p2 = l[$0 + 1]
     let p = percent.map { ($0 * p1) + ((1 - $0) * p2) }
     return p
 }
 let indices = l.indices.map { $0 }
 let evened = indices.reduce(into: [Point]()) {
     $0.append(l[$1])
     guard let p = new[$1] else { return }
     $0.append(contentsOf: p)
 }
 */
/*
 let distances = (l.startIndex...(l.endIndex - 1)).map {
     l[$0].distance(to: l[$0 + 1])
 }
 var all = [Float]()
 var accul: Float = .zero
 for d in distances {
     all.append(d + accul)
     accul = d + accul
 }
 let s: Float = all.last!
 print(l.count)
 let n = 123
 let division = Float(n - 1)
 let dist = (0...n-1).map { Float($0) * s / division }
 let equal = dist.map { d in
     guard !d.isZero else { return l[0] }
     let j = all.firstIndex { d <= $0 }!
     let i = j - 1
     let p2 = l[j]
     let p1 = l[i]
     let B = all[j]
     let A = all[i]
     let f = (d - A)/(B - A)
     return ((1 - f) * p1) + (f * p2)
 }
 let equalized = Loop(equal)
 
 Smooth = 0.10858586
 
  //let i = 3
  //let old = settings.model.loops[i]
  //let new = Loop(old.smoothen(by: smoo[i]))
  
  //print(old.formatted(.txt))
  //print(new.formatted(.txt))
 let min: Float = 0.484375
 let max: Float = 0.5
 let number: Float = 5
 let dis = (max-min)/(number - 1)
 let s = stride(from: min, through: max, by: dis).map { Float($0) }
 s.indices.forEach {
     let isGood = settings.model.welp(maxDistances: maxDistances, smoothness: s[$0])
     print("smooth: \(s[$0])", isGood)
 }
 // [0.125, 0.9453125, 0.125, 0.46875, 0.4921875]
 
 Text(settings.sections.selected, format: .list(memberStyle: .number, type: .and))
 
 Text(settings.model.smoothness, format: .number.precision(.significantDigits(2)))
     .frame(height: 40)
     .stamp()
     .font(.system(.title, design: .monospaced, weight: .light))
 */
struct Kernel {
    typealias Index = Array<Any>.Index
    enum Types { case box, triangle }
    
    var type: Types
    var count: Index
    var weights: [Float] {
        switch type {
        case .box: return boxed()
        case .triangle: return triangular()
        }
    }
    
    private var length: Float { Float(count - 1) }
    private var μ: Float { 0.5*length }
    
    func boxed() -> [Float] {
        guard count >= 1 else { return [] }
        return Array(repeating: 1 / Float(count), count: count)
    }
    
    func triangular() -> [Float] {
        guard count >= 3 else { return [] }
        return (0..<count).map { 1 - abs(Float($0) - μ)/μ }
    }
}

extension Loop {
    func convolve(with kernel: Kernel) -> Self? {
        guard self.count >= 3 else { return nil }
        guard kernel.count >= 3 else { return nil }
        guard kernel.count % 2 == 1 else { return nil }
        guard !kernel.weights.isEmpty else { return nil }
        let firstIndex = startIndex, lastIndex = endIndex - 1, half = kernel.count/2
        let lowerBound = firstIndex + half, upperBound = lastIndex - half
        guard lowerBound <= upperBound else { return nil }
        let weights = kernel.weights, summed = weights.reduce(0, +)
        let convolve = (lowerBound...upperBound).map { i in
            let selected = ((i - half)...(i + half)).map { self[$0] }
            let weighted = selected.indices.map { weights[$0] * selected[$0] }
            return weighted.reduce(Element.zero, +)/summed
        }
        let front = (firstIndex..<lowerBound).map { self[$0] }
        let back = ((upperBound + 1)...lastIndex).map { self[$0] }
        let convolved = front + convolve + back
        return Loop(convolved)
    }
}

extension Point {
    func distance(to line: (Self, Self)) -> Float {
        guard line.0 != line.1 else { return self.distance(to: line.0) }
        let a = self.x * (line.1.y - line.0.y) - self.y * (line.1.x - line.0.x)
        return abs(a + (line.1.x * line.0.y) - (line.1.y * line.0.x))
        / line.1.distance(to: line.0)
    }
}

struct Hull {
    var convexHull = [Point]()
    var given: [Point]
    
    init(_ points: [Point], convexHull: [Point] = [Point]()) {
        self.given = points.sorted { (a: Point, b: Point) -> Bool in
          return a.x < b.x
        }
        self.convexHull = convexHull
    }
    
    mutating func quickHull() {
        var pts = given
        let p1 = pts.removeFirst()
        let p2 = pts.removeLast()
        
        convexHull.append(p1)
        convexHull.append(p2)
        
        var s1 = [Point]()
        var s2 = [Point]()
        
        let lineVec1 = Point(x: p2.x - p1.x, y: p2.y - p1.y)
        
        for p in pts {
            let pVec1 = Point(x: p.x - p1.x, y: p.y - p1.y)
            let sign1 = lineVec1.x * pVec1.y - pVec1.x * lineVec1.y
            
            if sign1 > 0 {
                s1.append(p)
            } else {
                s2.append(p)
            }
        }
        
        findHull(s1, p1, p2)
        findHull(s2, p2, p1)
    }
    
    mutating func findHull(_ points: [Point], _ p1: Point, _ p2: Point) {
        guard !points.isEmpty else { return }
        
        var pts = points
        var maxDist: Float = -1
        var maxPoint: Point = pts.first!
        
        for p in pts {
            let dist = p.distance(to: (p1, p2))
            if dist > maxDist {
                maxDist = dist
                maxPoint = p
            }
        }
        
        convexHull.insert(maxPoint, at: convexHull.firstIndex(of: p1)! + 1)
        pts.remove(at: pts.firstIndex(of: maxPoint)!)
        
        var s1 = [Point]()
        var s2 = [Point]()
        
        let lineVec1 = Point(x: maxPoint.x - p1.x, y: maxPoint.y - p1.y)
        let lineVec2 = Point(x: p2.x - maxPoint.x, y: p2.y - maxPoint.y)
        
        for p in pts {
            let pVec1 = Point(x: p.x - p1.x, y: p.y - p1.y)
            let sign1 = lineVec1.x * pVec1.y - pVec1.x * lineVec1.y
            
            let pVec2 = Point(x: p.x - maxPoint.x, y: p.y - maxPoint.y)
            let sign2 = lineVec2.x * pVec2.y - pVec2.x * lineVec2.y
            if sign1 > 0 {
                s1.append(p)
            } else if sign2 > 0 {
                s2.append(p)
            }
        }
        
        findHull(s1, p1, maxPoint)
        findHull(s2, maxPoint, p2)
    }
}

func wiggleOut(from old: [Point], given set: Set<Point>, keep: Int) -> [Point] {
    var kept = [Point]()
    var temp = [Point]()
    for p in old {
        if set.contains(p) {
            if temp.count > keep {
                kept.append(contentsOf: temp)
            }
            temp.removeAll()
            
            kept.append(p)
            continue
        }
        temp.append(p)
    }
    if temp.count > keep {
        kept.append(contentsOf: temp)
    }
    return kept
}

func welp(_ loops: [Loop], maxDistances: [Float], smoothness λ: Float) -> [Bool] {
    let smooth = loops.map { $0.smoothen(by: λ) }.map { Loop($0) }
    let alrigth = loops.indices.map { i in
        let loop = loops[i]
        let smooth = smooth[i]
        let distances = loop.indices.map {
            loop[$0].distance(to: smooth[$0])
        }
        return distances.allSatisfy { $0 <= maxDistances[i] }
    }
    return alrigth
}
