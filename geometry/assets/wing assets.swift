import Foundation

let wing = Volume(
    "Cessna Citation X",
    with: replicated.map { Loop($0) },
    at: [0, 0.25, 0.5, 0.75, 1]
)!
