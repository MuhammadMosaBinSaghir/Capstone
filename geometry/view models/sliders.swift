import SwiftUI
import Sliders

struct Sliders: View {
    @Environment(\.colorScheme) var scheme
    
    @State var range: ClosedRange<Float> = 0.25...0.75
    
    @ViewBuilder private func contained() -> some View {
        RoundedRectangle(cornerRadius: 6).fill(.white).opacity(1)
    }
    
    @ViewBuilder private func container() -> some View {
        RoundedRectangle(cornerRadius: 6).foregroundStyle(.stamp(in: scheme))
    }
    
    @ViewBuilder private func gradient() -> some View {
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        RangeSlider(range: $range, in: 0...1, distance: 0.25...0.5)
            .rangeSliderStyle(
                HorizontalRangeSliderStyle(
                    track:
                        HorizontalRangeTrack(
                            view: gradient(),
                            mask: contained()
                        )
                        .background(container()),
                    lowerThumb: contained(),
                    upperThumb: contained(),
                    lowerThumbSize: CGSize(width: 7, height: 28),
                    upperThumbSize: CGSize(width: 7, height: 28),
                    options: .forceAdjacentValue
                )
            )
    }
}


