import AppKit
import UniformTypeIdentifiers

/// Asking the user to pick an app off the disk.
///
/// Uses the system's own panel, opening on the Applications folder because that is
/// where apps live, and leaving the user free to walk anywhere else they keep one.
/// Only an app can be picked, so a folder chosen by mistake never becomes a menu entry
/// that does nothing.
enum ApplicationPanel {

    /// Shows the panel and waits for an answer.
    ///
    /// - Returns: What the app calls itself and what the mac finds it by, or `nil` when
    ///   the user backed out or picked something that is not an app.
    static func ask() -> FoundApp? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(filePath: ApplicationPanelPlace.applicationsPath)
        panel.message = UIText.chooseApplication
        panel.prompt = UIText.choose

        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        return InstalledApps.found(at: url)
    }
}

/// Where the panel opens.
enum ApplicationPanelPlace {

    /// The folder a mac keeps its apps in, which is where the panel starts.
    static let applicationsPath = "/Applications"
}
