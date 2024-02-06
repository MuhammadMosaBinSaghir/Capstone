import SwiftUI

struct Contents: View {
    @Environment(\.settings) private var settings
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Volume(from: settings.model)
            Text(settings.sections.selected, format: .list(memberStyle: .number, type: .and))
            HStack(alignment: .center, spacing: 6) {
                Text(settings.model.smoothness, format: .number.precision(.significantDigits(2)))
                    .frame(height: 40)
                    .stamp()
                    .font(.system(.title, design: .monospaced, weight: .light))
                CrossSectionSelector(settings.sections)
                Popover()
            }
            .frame(height: 52)
        }
        .padding(6)
        .transparent()
        .ignoresSafeArea()
    }
}

