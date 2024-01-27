import SwiftUI

struct Contents: View {
    @State var plane: Float = 0.25
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(.clear)
            VStack {
                Volume(wing.label, with: wing.loops, at: wing.planes, showing: plane)!
                    .stroke(.white)
                    .animation(.default, value: plane)
                    .frame(width: 500, height: 500)
                    
                Slider(value: $plane, in: 0...1) {
                    Label("slide me", systemImage: "star")
                }
            }
        }
        .padding(6)
        .transparent()
        .ignoresSafeArea()
    }
}

#Preview { Contents() }
