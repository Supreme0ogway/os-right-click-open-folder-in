/// Whether what somebody typed can name an app in the list.
///
/// The same rules are asked twice: once on the screen that adds an app, and once on the
/// screen that changes one. Keeping them here means the two screens cannot drift, and
/// means the rules are checked without a screen at all.
///
/// Space around what was typed is never a fault. It is taken off, because nobody means
/// to name an app with a space on the end.

/// What is wrong with something somebody typed.
public enum AppProblem: Equatable, Sendable {

    /// Nothing was typed.
    case missing

    /// A space was typed inside, which a bundle name cannot hold.
    case holdsSpace

    /// A character was typed that no bundle name holds.
    case holdsPathCharacter

    /// A bundle name was typed with no dot, and every real one has parts.
    case missingDot

    /// More was typed than any real bundle name runs to.
    case tooLong
}

/// Checks the parts of an app in the list.
public enum AppCheck {

    /// What somebody typed, with the space taken off both ends.
    ///
    /// - Parameter text: What was typed.
    /// - Returns: The same text with nothing blank around it.
    public static func tidied(_ text: String) -> String {
        text.trimmed
    }

    /// What is wrong with the name shown in the menu, if anything.
    ///
    /// - Parameter text: What was typed.
    /// - Returns: The problem, or `nil` when it can be used.
    public static func nameProblem(_ text: String) -> AppProblem? {
        tidied(text).isEmpty ? .missing : nil
    }

    /// What is wrong with the bundle name the mac finds the app by, if anything.
    ///
    /// - Parameter text: What was typed.
    /// - Returns: The problem, or `nil` when it can be used.
    public static func bundleIdentifierProblem(_ text: String) -> AppProblem? {
        let clean = tidied(text)
        guard !clean.isEmpty else { return .missing }
        guard clean.count <= BundleIdentifierConstants.maximumLength else { return .tooLong }
        guard !clean.contains(where: \.isWhitespace) else { return .holdsSpace }
        guard holdsOnlyAllowed(clean) else { return .holdsPathCharacter }
        guard clean.contains(BundleIdentifierConstants.dot) else { return .missingDot }
        return nil
    }

    private static func holdsOnlyAllowed(_ text: String) -> Bool {
        let extra = BundleIdentifierConstants.extraCharacters
        return text.allSatisfy { character in
            character.isASCII
                && (character.isLetter || character.isNumber || extra.contains(character))
        }
    }
}
