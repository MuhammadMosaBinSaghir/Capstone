import SwiftUI

struct Contents: View {
    var body: some View {
        Volume(from: test)
        .padding(6)
        .transparent()
        .ignoresSafeArea()
    }
}

let test = CrossSection(
    "test",
    with:
        [Loop([Point(x: 1, y: 0),
               Point(x: 0.75, y: 0.25),
               Point(x: 0.2, y: 0.25),
               Point(x: 0, y: 0),
               Point(x: 0.2, y: -0.25),
               Point(x: 0.75, y: -0.25)]),
         Loop([Point(x: 1, y: 0),
               Point(x: 0.75, y: 0.25),
               Point(x: 0.25, y: 0.25),
               Point(x: 0, y: 0),
               Point(x: 0.25, y: -0.25),
               Point(x: 0.75, y: -0.25)]),
         Loop([Point(x: 1, y: 0),
               Point(x: 0.75, y: 0.25),
               Point(x: 0.25, y: 0.25),
               Point(x: 0, y: 0),
               Point(x: 0.25, y: -0.25),
               Point(x: 0.75, y: -0.25)])],
    at: [0, 0.5, 1]
)!
