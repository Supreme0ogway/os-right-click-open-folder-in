/// One app the right click menu can open a folder in.
///
/// A record, not a behaviour: it says what the app is called and what the mac finds it
/// by, and nothing about how it is launched or how its icon is drawn.
///
/// The icon is deliberately not kept here. A mac already has the icon for every
/// installed app, and a copy of one would only go stale the day the app is updated.

/// An app the menu can offer.
public struct OpenerApp: Hashable, Codable, Sendable, Identifiable {

    /// The name this entry is known by. Never shown to anybody.
    public let id: AppIdentifier

    /// What the user sees, such as `Visual Studio Code`.
    public let displayName: String

    /// What the mac finds the app by, such as `com.microsoft.VSCode`.
    public let bundleIdentifier: String

    /// Builds an app entry.
    ///
    /// - Parameters:
    ///   - id: The namespaced name for this entry.
    ///   - displayName: What the user sees in the menu and the editor. Blank falls back
    ///     to the bundle name, so an entry always has something to show.
    ///   - bundleIdentifier: What the mac finds the app by. Space around it is taken off.
    public init(id: AppIdentifier, displayName: String, bundleIdentifier: String) {
        let cleanBundleIdentifier = bundleIdentifier.trimmed
        let cleanName = displayName.trimmed

        self.id = id
        self.displayName = cleanName.isEmpty ? cleanBundleIdentifier : cleanName
        self.bundleIdentifier = cleanBundleIdentifier
    }
}
