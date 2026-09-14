import Foundation

/// Every word the screens show a person.
///
/// Looked up by key so the wording can change without touching the screens, and so a
/// control never holds words of its own.
public enum UIText {

    /// The app's name, shown at the top of its window.
    public static let appName = String(localized: "app.name", bundle: .module)

    /// Shown in place of the list when every app has been removed.
    public static let emptyTitle = String(localized: "editor.empty-title", bundle: .module)

    /// Explains that an empty list is allowed, and what it does.
    public static let emptyMessage = String(localized: "editor.empty-message", bundle: .module)

    /// Removes the app on this row.
    public static let remove = String(localized: "editor.remove", bundle: .module)

    /// The name shown in the right click menu.
    public static let name = String(localized: "editor.name", bundle: .module)

    /// The name the mac finds the app by.
    public static let bundleIdentifier = String(
        localized: "editor.bundle-identifier",
        bundle: .module
    )

    /// Shown on the right when no app has been picked yet.
    public static let nothingPickedTitle = String(
        localized: "editor.nothing-picked-title",
        bundle: .module
    )

    /// Tells the user to pick an app to change it.
    public static let nothingPickedMessage = String(
        localized: "editor.nothing-picked-message",
        bundle: .module
    )

    /// Shown when a search matched none of the apps.
    public static let noMatchesTitle = String(localized: "editor.no-matches-title", bundle: .module)

    /// Tells the user their search matched nothing.
    public static let noMatchesMessage = String(
        localized: "editor.no-matches-message",
        bundle: .module
    )

    /// The search box above the list of apps.
    public static let search = String(localized: "editor.search", bundle: .module)

    /// A few words under the name box.
    public static let nameHint = String(localized: "editor.name-hint", bundle: .module)

    /// A few words under the bundle name box saying what is allowed.
    public static let bundleIdentifierHint = String(
        localized: "editor.bundle-identifier-hint",
        bundle: .module
    )

    /// Shown on a row whose app is not on this mac.
    public static let notInstalled = String(localized: "editor.not-installed", bundle: .module)

    /// Makes this app the one a folder opens in by default.
    public static let makeDefault = String(localized: "editor.make-default", bundle: .module)

    /// Stops this app being the one a folder opens in by default, leaving none picked.
    public static let removeDefault = String(localized: "editor.remove-default", bundle: .module)

    /// Shown on the app a folder opens in by default.
    public static let isDefault = String(localized: "editor.is-default", bundle: .module)

    /// Goes back from the settings screen to the list of apps.
    public static let back = String(localized: "window.back", bundle: .module)

    /// Opens the settings screen.
    public static let settings = String(localized: "window.settings", bundle: .module)

    /// Adds an app, shown as a plus in the toolbar.
    public static let addApp = String(localized: "window.add-app", bundle: .module)

    /// Label for the dropdown of apps this mac can already open a folder with.
    public static let addFound = String(localized: "add.found", bundle: .module)

    /// The entry in the dropdown that lets a bundle name be typed in.
    public static let addCustom = String(localized: "add.custom", bundle: .module)

    /// Adds the app and closes the screen.
    public static let addConfirm = String(localized: "add.confirm", bundle: .module)

    /// Closes the add screen without adding anything.
    public static let addCancel = String(localized: "add.cancel", bundle: .module)

    /// What the bundle name box shows while it is empty.
    public static let bundleIdentifierPlaceholder = String(
        localized: "add.bundle-identifier-placeholder",
        bundle: .module
    )

    /// Opens the panel for picking an app off the disk.
    public static let browse = String(localized: "add.browse", bundle: .module)

    /// Shown in the dropdown while no app has been picked at all.
    public static let choosePrompt = String(localized: "add.choose-prompt", bundle: .module)

    /// The title of the panel for picking an app off the disk.
    public static let chooseApplication = String(
        localized: "add.choose-application",
        bundle: .module
    )

    /// Shows the menu in every folder.
    public static let everywhere = String(localized: "scope.everywhere", bundle: .module)

    /// Shows the menu only in folders the user picks.
    public static let pickedFolders = String(localized: "scope.picked-folders", bundle: .module)

    /// Explains that a picked folder also covers what is inside it.
    public static let pickedNote = String(localized: "scope.picked-note", bundle: .module)

    /// Opens the panel for picking a folder.
    public static let addFolder = String(localized: "scope.add-folder", bundle: .module)

    /// The title of the panel for picking a folder.
    public static let chooseFolder = String(localized: "scope.choose-folder", bundle: .module)

    /// Confirms the picked folder.
    public static let choose = String(localized: "scope.choose", bundle: .module)

    /// Explains that the menu now appears nowhere.
    public static let nowhereMessage = String(localized: "scope.nowhere-message", bundle: .module)

    /// Heading of the part of settings choosing where the menu appears.
    public static let scopeTitle = String(localized: "scope.title", bundle: .module)

    /// Heading of the part of settings choosing the app folders open in.
    public static let defaultAppTitle = String(localized: "default-app.title", bundle: .module)

    /// Label for the choice of which app a folder opens in.
    public static let defaultAppLabel = String(localized: "default-app.label", bundle: .module)

    /// The entry in the dropdown that picks no default at all.
    public static let defaultAppNone = String(localized: "default-app.none", bundle: .module)

    /// Explains what picking a default app does.
    public static let defaultAppNote = String(localized: "default-app.note", bundle: .module)

    /// Label for the second dropdown, revealed when another app is asked for.
    public static let defaultAppOtherLabel = String(
        localized: "default-app.other-label",
        bundle: .module
    )

    /// Explains that picking an app there adds it to the list as well.
    public static let defaultAppOtherNote = String(
        localized: "default-app.other-note",
        bundle: .module
    )

    /// Heading of the part of settings that moves apps in and out.
    public static let transferTitle = String(localized: "transfer.title", bundle: .module)

    /// Writes every app out to a file.
    public static let export = String(localized: "transfer.export", bundle: .module)

    /// Reads apps back in from a file.
    public static let importApps = String(localized: "transfer.import", bundle: .module)

    /// Explains what exporting and importing do.
    public static let transferNote = String(localized: "transfer.note", bundle: .module)

    /// Title of the panel for choosing where to write the apps.
    public static let chooseDestination = String(
        localized: "transfer.choose-destination",
        bundle: .module
    )

    /// Title of the panel for choosing a file of apps to read.
    public static let chooseSource = String(localized: "transfer.choose-source", bundle: .module)

    /// Shown when a file of apps cannot be read.
    public static let fileIsDamaged = String(localized: "transfer.file-is-damaged", bundle: .module)

    /// Heading of the part of settings saying what the app is.
    public static let aboutTitle = String(localized: "about.title", bundle: .module)

    /// Heading above the list of what changed in the newest release.
    public static let whatsNew = String(localized: "about.whats-new", bundle: .module)

    /// Shown beside opening at login while the user still has to allow it.
    public static let loginWaiting = String(localized: "login.waiting", bundle: .module)

    /// Explains that removing an app cannot be undone.
    public static let removeWarning = String(localized: "remove.warning", bundle: .module)

    /// Goes ahead with removing an app.
    public static let removeConfirm = String(localized: "remove.confirm", bundle: .module)

    /// Leaves the app alone.
    public static let removeCancel = String(localized: "remove.cancel", bundle: .module)

    /// Says which version the app is.
    ///
    /// - Parameter version: The version, such as `1.0.0`.
    /// - Returns: The sentence to show.
    public static func version(_ version: String) -> String {
        String(format: String(localized: "about.version", bundle: .module), version)
    }

    /// Asks whether an app should be removed.
    ///
    /// - Parameter name: What the app is called.
    /// - Returns: The question to show.
    public static func removeQuestion(_ name: String) -> String {
        String(format: String(localized: "remove.question", bundle: .module), name)
    }

    /// Says what is wrong with something somebody typed.
    ///
    /// - Parameter problem: What the check found, or `nil` when nothing is wrong.
    /// - Returns: The sentence to show, or `nil` when there is nothing to say.
    public static func saying(_ problem: AppProblem?) -> String? {
        switch problem {
        case .none: nil
        case .missing: String(localized: "problem.missing", bundle: .module)
        case .holdsSpace: String(localized: "problem.holds-space", bundle: .module)
        case .holdsPathCharacter:
            String(localized: "problem.holds-path-character", bundle: .module)
        case .missingDot: String(localized: "problem.missing-dot", bundle: .module)
        case .tooLong: String(localized: "problem.too-long", bundle: .module)
        }
    }
}
