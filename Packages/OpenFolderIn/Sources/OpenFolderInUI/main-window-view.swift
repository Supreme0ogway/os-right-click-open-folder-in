import SwiftUI

/// The app's one window.
///
/// It shows the apps, and the settings button swaps it for everything else, with a way
/// back. Layout only: which of the two is showing is the only thing it holds, and that
/// is where somebody looked, not what the app knows.
public struct MainWindowView: View {

    private let appList: AppListViewModel
    private let scope: ScopePickerViewModel
    private let transfer: TransferViewModel
    private let defaultApp: DefaultAppViewModel
    private let version: String

    @State private var showsSettings = false

    /// Builds the window.
    ///
    /// - Parameters:
    ///   - appList: The model for the list of apps.
    ///   - scope: The model for where the menu appears.
    ///   - transfer: The model for moving apps in and out.
    ///   - defaultApp: The model for which app a folder opens in by default.
    ///   - version: Which version the app is.
    public init(
        appList: AppListViewModel,
        scope: ScopePickerViewModel,
        transfer: TransferViewModel,
        defaultApp: DefaultAppViewModel,
        version: String
    ) {
        self.appList = appList
        self.scope = scope
        self.transfer = transfer
        self.defaultApp = defaultApp
        self.version = version
    }

    public var body: some View {
        content
            .frame(
                minWidth: WindowLayout.minimumWidth,
                minHeight: WindowLayout.minimumHeight
            )
            .tint(Brand.accent)
    }

    @ViewBuilder
    private var content: some View {
        if showsSettings {
            SettingsView(
                scope: scope,
                transfer: transfer,
                defaultApp: defaultApp,
                version: version
            ) { showsSettings = false }
        }

        if !showsSettings {
            AppListView(model: appList, defaultApp: defaultApp) { showsSettings = true }
        }
    }
}

/// Fixed sizes for the window.
enum WindowLayout {

    /// The narrowest the window may get.
    static let minimumWidth: CGFloat = 660

    /// The shortest the window may get.
    static let minimumHeight: CGFloat = 480
}
