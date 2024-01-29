import SwiftUI

struct Contents: View {
    @State var plane: Float = 0.25
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(.clear)
            VStack {
                Volume(wing.label, with: wing.loops, at: wing.planes, showing: plane)!
                    .animation(.default, value: plane)
                Slider(value: $plane, in: 0...1) {
                    Label("slide me", systemImage: "star")
                }
                .onAppear {
                    print(wing.loops[0].count)
                    print(wing.loops[0].map { $0.y })
                    
                    //let b = a.points
                    //let k = Kernel(type: .box, count: 3)
                    //print(k.weights)
                    //let c = b.convolve(with: k)
                    //let fastC = b.elements.WAT(with: k)
                    //let d = Loop(c)
                    //print(fastC?.text())
                }
            }
        }
        .padding(6)
        .transparent()
        .ignoresSafeArea()
    }
}

#Preview { Contents() }

let T = Volume(
    "",
    with:
        [
            Loop([Point(x: 0, y: 0), Point(x: 0.5, y: 0), Point(x: 1, y: 0), Point(x: 1, y: 0.5), Point(x: 1, y: 1)])!,
        ],
    at: [0]
)!
