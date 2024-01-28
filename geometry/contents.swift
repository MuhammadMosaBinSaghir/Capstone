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
                    let first = wing.loops[0]
                    let kernel = Kernel(type: .gaussian(σ: 0.5), count: 10)
                    let convolved = first.convolve(with: kernel)
                    print(convolved?.text())
                }
            }
        }
        .padding(6)
        .transparent()
        .ignoresSafeArea()
    }
}

#Preview { Contents() }
