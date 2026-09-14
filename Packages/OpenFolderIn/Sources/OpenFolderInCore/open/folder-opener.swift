import AppKit

/// Opening one folder in one app.
///
/// The one place in this app that launches anything. It checks the folder is really
/// there and the app is really installed, and then hands both to the system, which
/// already knows how to start an app and pass it a folder.
///
/// Deliberately not the place that decides whether it is allowed to open there. That is
/// the operating system's answer, and it arrives as a thrown error.

/// Why a folder could not be opened.
public enum FolderOpenerError: Error, Equatable, Sendable {

    /// Nothing is at the chosen path.
    case folderIsMissing

    /// Something is at the chosen path, but it is a file, not a folder.
    case notAFolder

    /// The app was moved, renamed or removed. Carries its bundle name.
    case appIsNotInstalled(String)

    /// The system refused to launch. Carries what it said.
    case openRefused(String)
}

/// Opens a folder in a chosen app.
///
/// - Note: Holds a file manager, which is not safe to hand between threads. Make one
///   where it is used rather than sharing it.
public struct FolderOpener {

    private let fileManager: FileManager

    /// Builds an opener.
    ///
    /// - Parameter fileManager: The file manager to work through. Defaults to the shared one.
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    /// Opens a folder in an app.
    ///
    /// - Parameters:
    ///   - folder: The folder to open. It must already exist.
    ///   - app: The app to open it in. It must be installed.
    /// - Throws: ``FolderOpenerError`` saying which step failed and why.
    public func open(_ folder: URL, in app: OpenerApp) async throws {
        try checkIsAFolder(folder)

        guard let applicationURL = InstalledApps.applicationURL(for: app.bundleIdentifier) else {
            throw FolderOpenerError.appIsNotInstalled(app.bundleIdentifier)
        }

        do {
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true
            try await NSWorkspace.shared.open(
                [folder],
                withApplicationAt: applicationURL,
                configuration: configuration
            )
        } catch {
            throw FolderOpenerError.openRefused(error.localizedDescription)
        }
    }

    private func checkIsAFolder(_ folder: URL) throws {
        var isFolder: ObjCBool = false
        let exists = fileManager.fileExists(atPath: folder.path, isDirectory: &isFolder)
        guard exists else { throw FolderOpenerError.folderIsMissing }
        guard isFolder.boolValue else { throw FolderOpenerError.notAFolder }
    }
}
