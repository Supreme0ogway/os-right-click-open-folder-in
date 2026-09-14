/// The choices the app remembers between launches.
///
/// Right now that is one choice: which app a folder opens in by default, the way a
/// file has a default app in the Finder's own Open With. Kept apart from the list of
/// apps and from where the menu appears, because losing one of those would matter and
/// losing this would not.
///
/// Nothing picked is a normal state. It means the menu offers apps and marks none of
/// them, which is what a first launch looks like and what removing the default leaves
/// behind.

/// What the app remembers.
public struct Preferences: Hashable, Codable, Sendable {

    /// The shape this was written in.
    public let version: Int

    /// The app a folder opens in by default, or `nil` when none is picked.
    ///
    /// An id that is no longer in the list is ignored rather than corrected, so
    /// removing an app can never leave the menu pointing at something that is gone.
    public let defaultAppId: AppIdentifier?

    /// What an app with nothing set up uses.
    public static let fallback = Self(defaultAppId: nil)

    /// Builds the choices.
    ///
    /// - Parameters:
    ///   - version: The shape they are written in. Defaults to today's.
    ///   - defaultAppId: The app a folder opens in by default, or `nil` for none.
    public init(
        version: Int = PreferencesConstants.schemaVersion,
        defaultAppId: AppIdentifier?
    ) {
        self.version = version
        self.defaultAppId = defaultAppId
    }

    /// The same choices with a different default app.
    ///
    /// - Parameter id: The app to open folders in, or `nil` to pick none.
    /// - Returns: A new set of choices. The original is untouched.
    public func defaulting(to id: AppIdentifier?) -> Self {
        Self(version: version, defaultAppId: id)
    }
}
