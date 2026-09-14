import AppKit
import FinderSync
import OpenFolderInCore
import os

/// The part of the app that lives inside the Finder.
///
/// It does three things and no more: say which folders it watches, hand back the menu
/// it is told to show, and pass a click on to the app. Every decision behind those
/// answers is worked out in the module it imports, where it can be tested without a
/// Finder to click in.
///
/// The menu is one entry with the apps hanging off it, so the Finder's own menu gains a
/// single line however many apps somebody has. Each app carries its own icon, and the
/// default one comes first and says so.
///
/// It runs in a sandbox and is not allowed to launch anything, which is why a click is
/// forwarded to the app rather than acted on here.
///
/// - Note: A menu handed to the Finder is packed up and sent to another process, and
///   only the plain parts of an entry survive that trip. Anything hung on an entry as
///   an object arrives as nothing, so which app was clicked travels as a number.
///
/// - Note: The folder that was clicked can only be asked for while the menu is being
///   built or inside the action it made. Asking later, or after any hop off this
///   thread, answers nothing.
final class FinderMenuExtension: FIFinderSync {

    private let log = Logger(
        subsystem: BundleConstants.appIdentifier,
        category: ExtensionLog.category
    )

    private var lastMenuKind: FIMenuKind = .contextualMenuForItems

    override init() {
        super.init()
        refreshWatchedFolders()
        log.info("started")
    }

    // MARK: - What the Finder asks for

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        lastMenuKind = menuKind

        guard targetFolder() != nil else { return nil }

        let list = readAppList()
        guard MenuPlan.hasAnythingToShow(list) else {
            log.info("no apps, showing no menu")
            return nil
        }

        let flyout = NSMenu(title: MenuPlan.parentTitle)
        for entry in MenuPlan.entries(for: list, defaultAppId: readDefaultAppId()) {
            flyout.addItem(item(for: entry, in: list))
        }

        let parent = NSMenuItem(title: MenuPlan.parentTitle, action: nil, keyEquivalent: "")
        parent.submenu = flyout

        let menu = NSMenu(title: "")
        menu.addItem(parent)
        log.info("built \(flyout.numberOfItems) entries for kind \(menuKind.rawValue)")
        return menu
    }

    private func item(for entry: MenuEntry, in list: AppList) -> NSMenuItem {
        let item = NSMenuItem(
            title: entry.title,
            action: #selector(openFolder(_:)),
            keyEquivalent: ""
        )
        item.target = self
        item.tag = entry.place
        item.image = icon(for: list.app(withId: entry.appId)?.bundleIdentifier)
        return item
    }

    private func icon(for bundleIdentifier: String?) -> NSImage? {
        guard let bundleIdentifier,
              let url = NSWorkspace.shared.urlForApplication(
                  withBundleIdentifier: bundleIdentifier
              )
        else { return nil }

        let image = NSWorkspace.shared.icon(forFile: url.path)
        image.size = NSSize(width: MenuIconSize.side, height: MenuIconSize.side)
        return image
    }

    override func beginObservingDirectory(at url: URL) {
        refreshWatchedFolders()
    }

    // MARK: - What a click does

    @objc private func openFolder(_ sender: NSMenuItem) {
        let list = readAppList()
        guard let entry = MenuPlan.entry(
            at: sender.tag,
            in: list,
            defaultAppId: readDefaultAppId()
        ) else {
            leaveNote("", folder: "", handedOver: false, note: ExtensionNote.noApp)
            return
        }
        let appText = entry.appId.text

        guard let folder = targetFolder() else {
            leaveNote(appText, folder: "", handedOver: false, note: ExtensionNote.noFolder)
            return
        }

        let request = LaunchRequest(appId: entry.appId, folderPath: folder.path)
        let opened = NSWorkspace.shared.open(request.url)
        leaveNote(
            appText,
            folder: folder.path,
            handedOver: opened,
            note: opened ? "" : ExtensionNote.notOpened
        )
    }

    private func leaveNote(_ appText: String, folder: String, handedOver: Bool, note: String) {
        RequestTrail(
            appId: appText,
            folderPath: folder,
            menuKind: Int(lastMenuKind.rawValue),
            handedOver: handedOver,
            note: note
        ).record()
        log.info("\(appText, privacy: .public) handedOver=\(handedOver)")
    }

    private func targetFolder() -> URL? {
        let controller = FIFinderSyncController.default()
        guard lastMenuKind == .contextualMenuForItems else {
            return MenuPlan.folderToOpen(selectedItems: [], container: controller.targetedURL())
        }
        return MenuPlan.folderToOpen(
            selectedItems: controller.selectedItemURLs() ?? [],
            container: controller.targetedURL()
        )
    }

    // MARK: - Reading what the app saved

    private func readAppList() -> AppList {
        guard let fileURL = SharedContainer.appListFileURL else {
            log.error("no shared folder, so no apps to show")
            return .empty
        }
        return RecordFile.read(from: fileURL, fallback: .empty)
    }

    private func readDefaultAppId() -> AppIdentifier? {
        guard let fileURL = SharedContainer.preferencesFileURL else { return nil }
        return RecordFile.read(from: fileURL, fallback: Preferences.fallback).defaultAppId
    }

    private func readScope() -> Scope {
        guard let fileURL = SharedContainer.scopeFileURL else { return .fallback }
        return RecordFile.read(from: fileURL, fallback: .fallback)
    }

    private func refreshWatchedFolders() {
        let folders = WatchList.folderURLs(for: readScope())
        FIFinderSyncController.default().directoryURLs = folders
        log.info("watching \(folders.count) folders")
    }
}

/// How big the icon beside each entry is drawn.
enum MenuIconSize {

    /// The side of the square an icon is drawn in, in points.
    static let side: CGFloat = 16
}

/// Where this extension's messages are filed.
enum ExtensionLog {

    /// The category every message from the Finder extension carries.
    static let category = "finder-extension"
}

/// What the extension writes down when a click does not reach the app.
enum ExtensionNote {

    /// The clicked entry pointed at an app the list no longer holds.
    static let noApp = "the clicked entry pointed at no app"

    /// The Finder would not say which folder was clicked.
    static let noFolder = "the Finder named no folder"

    /// The app could not be asked to open the folder.
    static let notOpened = "the app could not be opened"
}
