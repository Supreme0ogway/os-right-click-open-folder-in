import AppKit

/// An app sitting on this mac, before it has a place in anybody's list.
///
/// The two things a list entry needs and the disk can answer: what the app calls itself
/// and what the mac finds it by. No id, because an id belongs to the list it goes into.
public struct FoundApp: Hashable, Sendable {

    /// What the app calls itself, as the Finder shows it.
    public let displayName: String

    /// What the mac finds the app by, such as `com.apple.Terminal`.
    public let bundleIdentifier: String

    /// Builds a record of an app found on this mac.
    ///
    /// - Parameters:
    ///   - displayName: What the app calls itself.
    ///   - bundleIdentifier: What the mac finds the app by.
    public init(displayName: String, bundleIdentifier: String) {
        self.displayName = displayName
        self.bundleIdentifier = bundleIdentifier
    }
}

/// Which apps on this mac can open a folder.
///
/// The mac already keeps this answer, so nothing here works it out. Asking the system
/// means a newly installed editor turns up without this app being rebuilt, and an app
/// that was dragged to the bin stops being offered the moment it goes.
///
/// - Note: The answer is worked out from a real folder on disk, because the system's
///   answer is about a thing, not about a kind of thing.
public enum InstalledApps {

    /// The apps this mac can open a folder with, sorted by name.
    ///
    /// - Returns: One entry per app, each with an id nothing else in the answer shares.
    public static func thatCanOpenFolders() -> [OpenerApp] {
        let sorted = NSWorkspace.shared
            .urlsForApplications(toOpen: URL.homeDirectory)
            .compactMap(found)
            .sorted { $0.displayName.lowercased() < $1.displayName.lowercased() }

        var taken = Set<AppIdentifier>()
        return sorted.compactMap { app in
            guard let id = AppSuggestion.identifier(
                fromBundleIdentifier: app.bundleIdentifier,
                avoiding: taken
            ) else { return nil }
            taken.insert(id)
            return OpenerApp(
                id: id,
                displayName: app.displayName,
                bundleIdentifier: app.bundleIdentifier
            )
        }
    }

    /// The app sitting at this place on the disk.
    ///
    /// Anything that is not an app bundle answers `nil`, so a folder somebody picked by
    /// mistake never turns into a menu entry that does nothing.
    ///
    /// - Parameter url: Where to look, such as something picked in an open panel.
    /// - Returns: What the app calls itself and what the mac finds it by, or `nil`.
    public static func found(at url: URL) -> FoundApp? {
        guard let bundleIdentifier = Bundle(url: url)?.bundleIdentifier else { return nil }
        return FoundApp(displayName: name(of: url), bundleIdentifier: bundleIdentifier)
    }

    /// Whether this mac has the app with this bundle name.
    ///
    /// - Parameter bundleIdentifier: What the mac finds the app by.
    /// - Returns: `true` when the app is somewhere on this mac.
    public static func isInstalled(_ bundleIdentifier: String) -> Bool {
        applicationURL(for: bundleIdentifier) != nil
    }

    /// Where the app with this bundle name is.
    ///
    /// - Parameter bundleIdentifier: What the mac finds the app by.
    /// - Returns: Where it is, or `nil` when this mac does not have it.
    public static func applicationURL(for bundleIdentifier: String) -> URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier)
    }

    private static func name(of url: URL) -> String {
        FileManager.default.displayName(atPath: url.path)
    }
}
