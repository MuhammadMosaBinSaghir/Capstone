import SwiftUI

extension EnvironmentValues {
    var settings: Settings {
        get { self[SettingsKey.self] }
        set { self[SettingsKey.self] = newValue }
    }
}

private struct SettingsKey: EnvironmentKey {
    static var defaultValue: Settings = Settings()
}
