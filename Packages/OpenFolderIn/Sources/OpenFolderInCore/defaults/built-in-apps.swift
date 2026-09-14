import Foundation

/// The apps this one arrives knowing about.
///
/// Kept as a data file next to this one, not as code, so an app can be added or its
/// wording changed without touching Swift. The user's own list replaces it entirely the
/// first time they save one.

/// Reads the list of apps shipped inside this one.
public enum BuiltInApps {

    /// The apps this one arrives knowing about, installed or not.
    ///
    /// Answers with an empty list if the shipped file is missing or damaged, which
    /// would be a build mistake rather than anything a user did.
    ///
    /// - Returns: The shipped list, or an empty one.
    public static func load() -> AppList {
        guard let fileURL = Bundle.module.url(
            forResource: DefaultsConstants.builtInAppsResource,
            withExtension: DefaultsConstants.builtInAppsExtension
        ) else { return .empty }

        return RecordFile.read(from: fileURL, fallback: .empty)
    }

    /// The list a first run should start with, which is only what is really installed.
    ///
    /// Offering an app nobody has is a menu entry that does nothing, so the shipped
    /// list is a set of suggestions rather than a promise. Keeping none of them is
    /// allowed and means the menu starts empty.
    ///
    /// - Parameters:
    ///   - shipped: The apps this one arrives knowing about.
    ///   - isInstalled: Whether the mac has the app with this bundle name.
    /// - Returns: The shipped apps that are installed, in the shipped order.
    public static func startingList(
        from shipped: AppList,
        isInstalled: (String) -> Bool
    ) -> AppList {
        AppList(
            version: shipped.version,
            apps: shipped.apps.filter { isInstalled($0.bundleIdentifier) }
        )
    }

    /// The list a first run should start with, asking this mac what it has.
    ///
    /// - Returns: The shipped apps that are installed on this mac.
    public static func startingList() -> AppList {
        startingList(from: load(), isInstalled: InstalledApps.isInstalled)
    }
}
