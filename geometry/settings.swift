import Foundation

@Observable class Settings {
    var sections = CrossSections(in: 0...1, select: 5)
    var model = Model(
        "Cessna Citation X",
        with: replicated.map { Loop($0) },
        at: [0, 0.25, 0.5, 0.75, 1], 
        smoothness: 0
    )!
    var structure =
    Document.Structure(
        precision: 6,
        scale: Measurement(value: 25, unit: .millimeters)
    )
    
    var selected: [Loop] {
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
        var newloops: [Loop] = wiggled.map { l in
            let densities = (l.startIndex...(l.endIndex - 1)).map {
                2/l[$0].distance(to: l[$0 + 1])
            }
            guard let max = densities.max() else { return l }
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
            //EVEN OUT THE POINTS AFTER INTERPOLATION, CAUSE THEY'LL JUST BE CULLED
            let indices = l.indices.map { $0 }
            let evened = indices.reduce(into: [Point]()) {
                $0.append(l[$1])
                guard let p = new[$1] else { return }
                $0.append(contentsOf: p)
            }
            let k = Loop(evened)
            return k
        }
        return newloops
    }
}

/*
func loops(from sections: CrossSections) -> [Loop] {
    let filtered = self.sections.indices.filter { sections.region.contains(self.sections[$0])
    }
    let smooth = filtered.map { self.loops[$0].smoothen(by: self.smoothness) }
    return []
}
*/
