/// Names this app and the Finder extension both have to agree on, letter for letter.
///
/// No team is written down here. The folder the two share is named after whoever
/// signed them, and that is read back off the running bundle, so this source builds
/// for anybody with their own account and nothing to edit.
public enum BundleConstants {

    /// This app's bundle name.
    public static let appIdentifier = "com.willlattus.open-folder-in"

    /// The Finder extension's bundle name. Has to sit under this app's.
    public static let extensionIdentifier = appIdentifier + ".finder-extension"

    /// The middle part of the shared folder's name, between the team and the app.
    public static let appGroupInfix = ".group."

    /// The address that starts this app and asks it to open a folder.
    public static let urlScheme = "open-folder-in"

    /// The shared folder's name for a given team.
    ///
    /// - Parameter team: The team that signed the bundle.
    /// - Returns: The name the system knows the shared folder by.
    public static func appGroupIdentifier(team: String) -> String {
        team + appGroupInfix + appIdentifier
    }
}
