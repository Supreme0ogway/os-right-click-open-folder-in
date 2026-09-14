/// Fixed facts about a list of apps, agreed by this app and the Finder extension.
public enum AppListConstants {

    /// The shape lists are written in today. Every written list carries it.
    public static let schemaVersion = 1

    /// The name of the file the list is kept in, inside the shared container.
    public static let fileName = "app-list.json"

    /// How many apps the list will hold. High enough never to be met by hand.
    public static let maximumAppCount = 200
}

/// Fixed facts about a bundle name, which is how a mac tells one app from another.
public enum BundleIdentifierConstants {

    /// The character between the parts of a bundle name, as in `com.apple.Terminal`.
    public static let dot = "."

    /// Characters a bundle name may hold, beyond letters and digits.
    public static let extraCharacters = "-."

    /// The longest bundle name the editor will take. Real ones are far shorter.
    public static let maximumLength = 120
}

/// Fixed facts about taking a list of apps in and out of this app.
public enum TransferConstants {

    /// What a written out list of apps is called by default.
    public static let suggestedFileName = "open-folder-in-apps.json"
}
