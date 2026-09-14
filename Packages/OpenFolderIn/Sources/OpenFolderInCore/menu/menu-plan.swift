import Foundation

/// Working out what the right click menu should offer, and for which folder.
///
/// The Finder extension asks this and builds exactly what it is told, so the decision
/// about what appears lives here where it can be tested without a Finder.
///
/// The important answer is the empty one. A list with nothing in it plans nothing, and
/// the extension shows no menu at all rather than an empty group, so somebody who
/// removed every app gets a right click menu that looks untouched.

/// One thing the menu offers.
public struct MenuEntry: Hashable, Sendable {

    /// What the entry says, already looked up in the user's language.
    public let title: String

    /// The app this entry opens the folder in.
    public let appId: AppIdentifier

    /// Where this entry sits in the menu, counting from zero.
    ///
    /// The number is how a click finds its way back to an app. A menu handed to the
    /// Finder is packed up and sent to another process, and only the plain parts of
    /// an entry survive that trip, so the app has to travel as a number.
    public let place: Int

    /// Whether this is the app a folder opens in unless another is picked.
    public let isDefault: Bool
}

/// Turns a list of apps into the entries the menu should hold.
public enum MenuPlan {

    /// The entries for this list, in the order they should appear.
    ///
    /// The default app comes first and says so, the way the Finder's own Open With
    /// puts a file's default app at the top of its list.
    ///
    /// - Parameters:
    ///   - list: The apps the user has.
    ///   - defaultAppId: The app a folder opens in unless another is picked. An id that
    ///     is no longer in the list marks nothing and moves nothing.
    /// - Returns: One entry per app. Empty when the list is empty.
    public static func entries(for list: AppList, defaultAppId: AppIdentifier?) -> [MenuEntry] {
        let wanted = defaultAppId.flatMap(list.app(withId:))?.id
        let first = list.apps.filter { $0.id == wanted }
        let rest = list.apps.filter { $0.id != wanted }

        return (first + rest).enumerated().map { place, app in
            MenuEntry(
                title: title(for: app, isDefault: app.id == wanted),
                appId: app.id,
                place: place,
                isDefault: app.id == wanted
            )
        }
    }

    /// Finds the entry a click came from.
    ///
    /// - Parameters:
    ///   - place: The number the clicked entry carried.
    ///   - list: The apps as they stand now.
    ///   - defaultAppId: The app a folder opens in unless another is picked.
    /// - Returns: The entry, or `nil` when the list changed since the menu was built.
    public static func entry(
        at place: Int,
        in list: AppList,
        defaultAppId: AppIdentifier?
    ) -> MenuEntry? {
        let all = entries(for: list, defaultAppId: defaultAppId)
        guard all.indices.contains(place) else { return nil }
        return all[place]
    }

    /// What the one entry in the right click menu is called.
    ///
    /// The apps hang off it rather than sitting in the menu themselves, so the Finder's
    /// own menu gains a single line however many apps somebody has.
    public static var parentTitle: String {
        String(
            localized: "menu.parent",
            bundle: .module,
            comment: "The one entry added to the right click menu"
        )
    }

    /// Whether a menu should be shown at all.
    ///
    /// When this is `false` the extension must show nothing, not an empty menu, so the
    /// Finder draws no heading and no separator of its own.
    ///
    /// - Parameter list: The apps the user has.
    /// - Returns: `true` when there is at least one entry to show.
    public static func hasAnythingToShow(_ list: AppList) -> Bool {
        !list.isEmpty
    }

    /// Which folder a click should open, out of what the Finder said was clicked.
    ///
    /// One folder clicked is that folder. Nothing clicked means the background of a
    /// window was, and then the folder is the one that window is showing. Anything
    /// else — a file, or several things at once — is not one folder, and the menu is
    /// not shown at all.
    ///
    /// - Parameters:
    ///   - selectedItems: What the Finder says is selected. Empty for a background click.
    ///   - container: The folder the window is showing, when the Finder names one.
    /// - Returns: The folder to open, or `nil` when there is not exactly one.
    ///
    /// - Note: Folders are told apart by the trailing slash the Finder puts on their
    ///   addresses, not by asking the disk. Asking the disk while the menu is being
    ///   built is somebody's frozen right-click.
    public static func folderToOpen(selectedItems: [URL], container: URL?) -> URL? {
        guard !selectedItems.isEmpty else { return folder(container) }
        guard selectedItems.count == 1 else { return nil }
        return folder(selectedItems.first)
    }

    private static func folder(_ url: URL?) -> URL? {
        guard let url, url.hasDirectoryPath else { return nil }
        return url
    }

    private static func title(for app: OpenerApp, isDefault: Bool) -> String {
        guard isDefault else { return app.displayName }
        return String(format: defaultFormat, app.displayName)
    }

    private static let defaultFormat = String(
        localized: "menu.default",
        bundle: .module,
        comment: "Marks the app a folder opens in unless another is picked"
    )
}
