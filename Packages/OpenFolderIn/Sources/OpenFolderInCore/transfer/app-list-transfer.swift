import Foundation

/// Taking a list of apps out of this app and bringing one back in.
///
/// Written as plain JSON, the same shape this app keeps on disk, so a list can be kept
/// as a backup, put in a repository, or handed to somebody else.
///
/// Bringing a list in adds to what is already there rather than replacing it. An app
/// that shares an id with one already in the list takes its place and keeps it, so
/// bringing the same file in twice changes nothing the second time.

/// Why a list of apps could not be read.
public enum AppListTransferError: Error, Equatable, Sendable {

    /// The file was not a list of apps, or was damaged.
    case cannotBeRead
}

/// Writes a list of apps out, and reads one back in.
public enum AppListTransfer {

    /// What a written out file is called by default.
    public static let suggestedFileName = TransferConstants.suggestedFileName

    /// Turns a list of apps into the contents of a file.
    ///
    /// - Parameter list: The apps to write out.
    /// - Returns: The file's contents, as sorted and spaced JSON.
    /// - Throws: Whatever the encoder throws, which nothing here is expected to cause.
    public static func data(for list: AppList) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(list)
    }

    /// Reads a list of apps out of a file's contents.
    ///
    /// - Parameter data: What was in the file.
    /// - Returns: The apps it held.
    /// - Throws: ``AppListTransferError/cannotBeRead`` for anything that is not a list
    ///   of apps, damaged or otherwise.
    public static func list(from data: Data) throws -> AppList {
        guard let list = try? JSONDecoder().decode(AppList.self, from: data) else {
            throw AppListTransferError.cannotBeRead
        }
        return list
    }

    /// Puts a list that came in together with the one already there.
    ///
    /// - Parameters:
    ///   - incoming: The apps that came in.
    ///   - existing: The apps already in this app.
    /// - Returns: The two together. A shared id keeps its place and takes the new app.
    public static func joining(_ incoming: AppList, into existing: AppList) -> AppList {
        incoming.apps.reduce(existing) { list, app in list.adding(app) }
    }
}
