import Foundation
import OpenFolderInCore

/// The one place this app's stores are made.
///
/// Everything below gets them handed to it, so nothing has to go looking and a test
/// can hand in its own. Made once, when the app starts, and never replaced.
///
/// When the shared folder cannot be reached the stores fall back to files inside this
/// app's own folder. The app then still runs and still opens folders; only the Finder
/// extension stops seeing the list, which the menu bar says out loud.
@MainActor
final class AppServices {

    /// The apps the user has.
    let appList: RecordStore<AppList>

    /// Where the menu is allowed to appear.
    let scope: RecordStore<Scope>

    /// The choices the app remembers between launches.
    let preferences: RecordStore<Preferences>

    /// Whether this app and the Finder extension can actually share files.
    let sharesWithExtension: Bool

    /// Builds the stores and puts the shipped apps in place on a first run.
    init() {
        let folder = Self.storageFolder()
        sharesWithExtension = SharedContainer.canBeWrittenTo()

        appList = RecordStore(
            fileURL: folder.appending(path: AppListConstants.fileName),
            fallback: BuiltInApps.startingList()
        )
        scope = RecordStore(
            fileURL: folder.appending(path: ScopeConstants.fileName),
            fallback: .fallback
        )
        preferences = RecordStore(
            fileURL: folder.appending(path: PreferencesConstants.fileName),
            fallback: .fallback
        )

        saveFirstRunDefaults()
    }

    private func saveFirstRunDefaults() {
        try? appList.save(appList.value)
        try? scope.save(scope.value)
        try? preferences.save(preferences.value)
    }

    private static func storageFolder() -> URL {
        guard let shared = SharedContainer.folderURL else { return fallbackFolder() }
        return shared
    }

    private static func fallbackFolder() -> URL {
        URL.applicationSupportDirectory.appending(path: BundleConstants.appIdentifier)
    }
}
