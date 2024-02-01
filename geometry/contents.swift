import SwiftUI

struct Contents: View {
    @State var λ = 10.0
    @State var I = 10.0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(.clear)
            VStack {
                Loop(smoothen(points[0], λ: λ, I: Int(I)))!
                    .stroke(.primary)
                    .animation(.default, value: λ)
                    .animation(.default, value: I)
                Slider(value: $λ, in: 0...100, step: 5)
                Slider(value: $I, in: 1...100, step: 5)
            }
            .onAppear {
                print(points[0].smoothen(by: 1, repetitions: 12).text())
                //print(smoothen(points[0], λ: 1, I: 12).text())
            }
        }
        .padding(6)
        .transparent()
        .ignoresSafeArea()
    }
}
