/// Working out a name and an id for an app the mac knows about.
///
/// A bundle name such as `com.microsoft.VSCode` is what the mac finds an app by, and an
/// id such as `user.found:vscode` is what this app's own list calls it. The two are
/// kept apart so a bundle name can change without every saved list going stale.
///
/// Nothing here is shown to anybody. The words in the menu are the app's own name.

/// Turns a bundle name into an id nothing else in the list is using.
public enum AppSuggestion {

    /// The namespace an app found on this mac belongs to.
    public static let namespace = IdentifierConstants.userNamespacePrefix + ".found"

    /// The short name to call an app, taken from the end of its bundle name.
    ///
    /// Anything an id cannot hold becomes a hyphen, and a bundle name that comes out
    /// empty falls back to something usable so an id can always be built.
    ///
    /// - Parameter bundleIdentifier: What the mac finds the app by.
    /// - Returns: Lowercase letters, digits and hyphens.
    public static func name(fromBundleIdentifier bundleIdentifier: String) -> String {
        let lastPart = bundleIdentifier
            .split(separator: Character(BundleIdentifierConstants.dot))
            .last
            .map(String.init) ?? ""

        let cleaned = String(lastPart.lowercased().map(allowedOrHyphen))
        let trimmed = cleaned.trimmingHyphens
        return trimmed.isEmpty ? fallbackName : trimmed
    }

    /// An id for this app that nothing else in the list is using.
    ///
    /// Counts up rather than handing back one already taken, so adding the same app
    /// twice makes a second entry instead of quietly replacing the first.
    ///
    /// - Parameters:
    ///   - bundleIdentifier: What the mac finds the app by.
    ///   - taken: The ids already in use.
    /// - Returns: A free id, or `nil` when the list is already as long as it may get.
    public static func identifier(
        fromBundleIdentifier bundleIdentifier: String,
        avoiding taken: Set<AppIdentifier>
    ) -> AppIdentifier? {
        let stem = name(fromBundleIdentifier: bundleIdentifier)

        for attempt in 1...AppListConstants.maximumAppCount {
            let suffix = attempt == 1 ? "" : "-\(attempt)"
            guard let candidate = try? AppIdentifier("\(namespace):\(stem)\(suffix)") else {
                return nil
            }
            guard taken.contains(candidate) else { return candidate }
        }
        return nil
    }

    private static let fallbackName = "app"

    private static let hyphen: Character = "-"

    private static func allowedOrHyphen(_ character: Character) -> Character {
        let isAllowed = character.isASCII && (character.isLetter || character.isNumber)
        return isAllowed ? character : hyphen
    }
}

extension String {

    /// The text with any hyphens taken off both ends, so no id starts or ends with one.
    fileprivate var trimmingHyphens: String {
        let front = drop { $0 == "-" }
        return String(front.reversed().drop { $0 == "-" }.reversed())
    }
}
