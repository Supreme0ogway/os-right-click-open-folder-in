import Foundation

/// What the Finder extension did the last time somebody clicked an entry.
///
/// The extension runs inside the Finder where its messages cannot always be read back,
/// so it writes down what happened in the folder it shares with this app. One note,
/// overwritten each time. It is the only way to tell a click that never arrived from a
/// click that arrived and was refused.

/// A note of one click and what came of it.
public struct RequestTrail: Codable, Equatable, Sendable {

    /// When the click happened.
    public let when: Date

    /// The app the folder was to be opened in.
    public let appId: String

    /// The folder the Finder named, or empty when it named none.
    public let folderPath: String

    /// Which kind of menu the click came from.
    public let menuKind: Int

    /// Whether this app was successfully asked to open the folder.
    public let handedOver: Bool

    /// What went wrong, or empty when nothing did.
    public let note: String

    /// Writes a note of one click.
    ///
    /// - Parameters:
    ///   - appId: The app the folder was to be opened in.
    ///   - folderPath: The folder the Finder named.
    ///   - menuKind: Which kind of menu the click came from.
    ///   - handedOver: Whether this app was successfully asked.
    ///   - note: What went wrong, if anything.
    public init(
        appId: String,
        folderPath: String,
        menuKind: Int,
        handedOver: Bool,
        note: String
    ) {
        self.when = Date()
        self.appId = appId
        self.folderPath = folderPath
        self.menuKind = menuKind
        self.handedOver = handedOver
        self.note = note
    }

    /// Leaves this note where this app and a person can both read it.
    public func record() {
        guard let fileURL = SharedContainer.trailFileURL else { return }
        try? RecordFile.write(self, to: fileURL)
    }
}
