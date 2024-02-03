import SwiftUI

struct Contents: View {
    @State var plane: Float = 0
    @State var smoothness: Float = 0
    
    var body: some View {
        VStack {
            Volume(wing.label, with: wing.loops, at: wing.planes, showing: plane, smoothness: smoothness)!
            .animation(.default, value: plane)
            .animation(.default, value: smoothness)
            Slider(value: $plane, in: 0...1)
            Slider(value: $smoothness, in: 0...100)
        }
        .padding(6)
        .transparent()
        .ignoresSafeArea()
    }
}
