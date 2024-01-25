import Foundation
import OrderedCollections
// All loops have the same number of points

// Loops in a wing are always unique
// Same # of loops and planes
// a wing must at least have 1 loop
// must be given the planes where these loops lie, these planes are z-coordinates
// Normalize the planes and sort them with their associated list

struct Wing {
    let label: String
    let loops: OrderedSet<Loop>
    let planes: OrderedSet<Float>
    
    init?(_ label: String, with loops: OrderedSet<Loop>, at planes: OrderedSet<Float>) {
        self.label = label
        guard !loops.isEmpty && loops.count == planes.count else { return nil }
        let (jagged, minimum, _ ) = loops.isJagged()
        // if just one loop, then it should return immediatly because if not, division by zero
        let base = """
        1,0
        0.75,0.75
        0.5,0.5
        0.25,0.25
        0,0
        0.25,-0.25
        0.5,-0.5
        0.75,-0.75
        """
        let d = loops[0].decimated(removing: 2)
        print(d?.text())
        
        let (planes, loops) = planes.normalized(with: loops)
        self.loops = OrderedSet(loops)
        self.planes = OrderedSet(planes)
    }
    
}


// func that if not jagged, return the array, but if jagged, decimates to minimum
