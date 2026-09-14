/// The name an app in the list is known by, everywhere, forever.
///
/// An id is a namespace and a name either side of a colon, such as `core:vscode`. The
/// namespace says who the entry came from, so an app the user added can never collide
/// with one shipped in this app.
///
/// Not a bundle name and not a display name. Nothing here is ever shown to anybody, and
/// nothing here is what the mac uses to find the app on disk.

/// Why a piece of text could not be read as an id.
public enum AppIdentifierError: Error, Equatable, Sendable {

    /// The text held no separator, or held more than one.
    case missingSeparator

    /// There was nothing before the separator.
    case emptyNamespace

    /// There was nothing after the separator.
    case emptyName

    /// A character appeared that ids do not allow.
    case invalidCharacter
}

/// A namespaced name for one app in the list, checked when it is made.
///
/// Holding one is proof it is well formed: there is no way to make an invalid one,
/// so nothing downstream has to check it again.
public struct AppIdentifier: Hashable, Sendable {

    /// Who the entry came from, such as `core` or `user.will`.
    public let namespace: String

    /// What the entry is called within its namespace, such as `vscode`.
    public let name: String

    /// Builds an id from text such as `core:vscode`.
    ///
    /// - Parameter text: Namespace and name either side of a single colon.
    /// - Throws: ``AppIdentifierError`` saying which rule the text broke.
    public init(_ text: String) throws {
        let parts = text.split(
            separator: IdentifierConstants.separator,
            omittingEmptySubsequences: false
        )
        guard parts.count == IdentifierConstants.partCount else {
            throw AppIdentifierError.missingSeparator
        }

        let namespace = String(parts[0])
        let name = String(parts[1])
        guard !namespace.isEmpty else { throw AppIdentifierError.emptyNamespace }
        guard !name.isEmpty else { throw AppIdentifierError.emptyName }

        let namespaceIsClean = Self.holdsOnlyAllowed(
            namespace,
            extra: IdentifierConstants.namespaceExtraCharacters
        )
        let nameIsClean = Self.holdsOnlyAllowed(
            name,
            extra: IdentifierConstants.nameExtraCharacters
        )
        guard namespaceIsClean, nameIsClean else {
            throw AppIdentifierError.invalidCharacter
        }

        self.namespace = namespace
        self.name = name
    }

    /// The id written back out, the same way it was written in.
    public var text: String {
        "\(namespace)\(IdentifierConstants.separator)\(name)"
    }

    private static func holdsOnlyAllowed(_ part: String, extra: String) -> Bool {
        part.allSatisfy { character in
            character.isASCII
                && (character.isLetter || character.isNumber || extra.contains(character))
        }
    }
}

// MARK: - Reading and writing

extension AppIdentifier: Codable {

    /// Reads an id from a plain string, refusing a malformed one rather than carrying it.
    ///
    /// - Parameter decoder: The decoder holding the string.
    /// - Throws: A decoding error if the value is not a string, or the reason it is not an id.
    public init(from decoder: any Decoder) throws {
        try self.init(try decoder.singleValueContainer().decode(String.self))
    }

    /// Writes the id as a plain string, so the list file stays readable by a person.
    ///
    /// - Parameter encoder: The encoder to write into.
    /// - Throws: Whatever the encoder throws.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(text)
    }
}

// MARK: - Sorting

extension AppIdentifier: Comparable {

    /// Orders ids by namespace, then by name, so a written list has a stable order.
    ///
    /// - Parameters:
    ///   - lhs: The id on the left.
    ///   - rhs: The id on the right.
    /// - Returns: `true` when `lhs` sorts before `rhs`.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.namespace, lhs.name) < (rhs.namespace, rhs.name)
    }
}
