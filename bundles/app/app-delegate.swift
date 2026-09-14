import AppKit
import OpenFolderInCore
import os

/// What this app does when the Finder extension asks it to open a folder.
///
/// The extension cannot launch anything itself, so every click in the right click menu
/// arrives here as an address. This reads it, finds the app that was asked for, and
/// hands both to the system.
///
/// A refused open is said out loud rather than swallowed: a menu that appears to do
/// nothing is worse than one that explains itself.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    /// The stores, made once when the app starts.
    let services = AppServices()

    /// The one window, made once and kept.
    lazy var editor = EditorWindow(services: services)

    private let log = Logger(subsystem: BundleConstants.appIdentifier, category: "app")

    func applicationDidFinishLaunching(_ notification: Notification) {
        let key = NSApplication.launchIsDefaultUserInfoKey
        let openedByHand = notification.userInfo?[key] as? Bool ?? true
        guard openedByHand else { return }
        editor.show()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        guard !hasVisibleWindows else { return true }
        editor.show()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            handle(url)
        }
    }

    private func handle(_ url: URL) {
        log.info("opened with \(url.absoluteString, privacy: .public)")
        guard let request = LaunchRequest(url: url) else {
            report(AppText.requestNotUnderstood)
            return
        }
        Task { await openFolder(for: request) }
    }

    private func openFolder(for request: LaunchRequest) async {
        services.appList.reload()
        guard let app = services.appList.value.app(withId: request.appId) else {
            report(AppText.appNoLongerExists)
            return
        }

        do {
            try await FolderOpener().open(URL(filePath: request.folderPath), in: app)
            log.info("opened \(request.folderPath, privacy: .public)")
        } catch let error as FolderOpenerError {
            report(AppText.saying(error))
        } catch {
            report(error.localizedDescription)
        }
    }

    private func report(_ message: String) {
        let alert = NSAlert()
        alert.messageText = AppText.couldNotOpen
        alert.informativeText = message
        alert.alertStyle = .warning
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
