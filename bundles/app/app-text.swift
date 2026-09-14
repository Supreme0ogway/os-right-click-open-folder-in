import Foundation
import OpenFolderInCore

/// Every word this app shows a person.
///
/// Kept together and looked up by key, so the wording can be changed or translated
/// without going through the code that shows it.
enum AppText {

    /// Title of the warning shown when a folder could not be opened.
    static let couldNotOpen = String(localized: "app.could-not-open")

    /// Shown when the Finder sent an address this app cannot read.
    static let requestNotUnderstood = String(localized: "app.request-not-understood")

    /// Shown when the app was removed from the list between the menu opening and the click.
    static let appNoLongerExists = String(localized: "app.app-no-longer-exists")

    /// The name this app is known by in the menu bar.
    static let menuTitle = String(localized: "app.menu-title")

    /// Opens the window where apps are added and removed.
    static let editApps = String(localized: "app.edit-apps")

    /// Closes the app.
    static let quit = String(localized: "app.quit")

    /// Shown when the Finder extension has not been switched on yet.
    static let extensionIsOff = String(localized: "app.extension-is-off")

    /// Shown when the app and the extension cannot share files.
    static let notSharing = String(localized: "app.not-sharing")

    /// Shown when the scope was narrowed to no folders at all.
    static let appearsNowhere = String(localized: "app.appears-nowhere")

    /// Shown when every app has been removed.
    static let noApps = String(localized: "app.no-apps")

    /// Makes the app start when the mac starts.
    static let openAtLogin = String(localized: "app.open-at-login")

    /// Says why the folder could not be opened.
    ///
    /// - Parameter error: What the opener threw.
    /// - Returns: The reason, in the user's language.
    static func saying(_ error: FolderOpenerError) -> String {
        switch error {
        case .folderIsMissing: String(localized: "app.folder-is-missing")
        case .notAFolder: String(localized: "app.not-a-folder")
        case .appIsNotInstalled(let bundleIdentifier):
            String(format: String(localized: "app.app-is-not-installed"), bundleIdentifier)
        case .openRefused(let reason):
            String(format: String(localized: "app.open-refused"), reason)
        }
    }
}
