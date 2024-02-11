import SwiftUI
import Sliders

struct CrossSectionSelector: View {
    @Bindable private var sections: CrossSections
    @Environment(\.colorScheme) var scheme
    
    init(_ sections: CrossSections) { self.sections = sections }
    
    @ViewBuilder private func contained() -> some View {
        RoundedRectangle(cornerRadius: 3).fill(.white).opacity(1)
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
        RangeSlider(range: $sections.region, in: 0...1, distance: 0.25...1)
            .rangeSliderStyle(
                HorizontalRangeSliderStyle(
                    track:
                        HorizontalRangeTrack(
                            view: gradient(),
                            mask: contained()
                        )
                        .background(container())
                        .frame(height: 32),
                    lowerThumb: contained(),
                    upperThumb: contained(),
                    lowerThumbSize: CGSize(width: 4, height: 32),
                    upperThumbSize: CGSize(width: 4, height: 32),
                    options: .forceAdjacentValue
                )
            )
    }
}


