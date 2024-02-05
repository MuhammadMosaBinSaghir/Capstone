import SwiftUI

extension ShapeStyle where Self == Color {
    static func stamp(in scheme: ColorScheme) -> Color {
        StampShapeStyle.color(in: scheme)
    }
}

struct StampShapeStyle: ShapeStyle {
    static func color(in scheme: ColorScheme) -> Color {
        scheme == .light ? Color.primary.opacity(0.2) : .gray.opacity(0.1)
    }
}

