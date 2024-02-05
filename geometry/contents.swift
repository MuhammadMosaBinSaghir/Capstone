import SwiftUI

struct Contents: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Volume(from: wing)
            HStack(alignment: .center, spacing: 6) {
                Text(0.5, format: .number.precision(.fractionLength(2)))
                    .frame(height: 40)
                    .stamp()
                
                    .font(.system(.title, design: .monospaced, weight: .light))
                    
                Sliders()
                Popover()
            }
            .frame(height: 52)
        }
        .padding(6)
        .transparent()
        .ignoresSafeArea()
    }
}
