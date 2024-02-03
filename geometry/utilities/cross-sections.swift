import Foundation

extension CrossSection {
    func vertices() -> [Coordinate] {
        self.loops.indices.reduce(into: [Coordinate]()) { coordinates, i in
            coordinates += loops[i].map { $0.projected(onto: self.planes[i]) }
        }
    }
    
    func indices() -> [UInt16] {
        let loops = self.loops.count
        let points = self.loops[0].count
        let indices =
        (0...(loops-2)).reduce(into: [Int]()) { indices, j in
            (0...(points-2)).forEach { i in
                indices +=
                [i + j*points,
                 (i + 1 + j*points) %% ((j + 1)*points),
                 i + (j+1)*points,
                 i + 1 + (j+1)*points,
                 i + (j+1)*points,
                 (i + 1 + j*points) %% ((j + 1)*points)]
            }
            indices += [(j + 1) * points - 1,
                        j*points,
                        (j + 2) * points - 1,
                        (j + 1) * points,
                        (j + 2) * points - 1,
                        j*points]
        }
        return indices.map { UInt16($0) }
    }
}
