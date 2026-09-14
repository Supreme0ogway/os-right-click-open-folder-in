import Observation

/// What the setting for the app folders open in knows and can do.
///
/// Follows both stores and writes every change back through them, so the menu reads the
/// same answer this setting shows.
///
/// A default whose app was removed is left in the file rather than cleared. Clearing it
/// would throw the choice away for good when somebody puts the app back. It is simply
/// not shown as picked while the app is gone.
@MainActor
@Observable
public final class DefaultAppViewModel {

    /// The store the choice is kept in.
    public let store: RecordStore<Preferences>

    /// The apps this mac can open a folder with, offered under ``isOther``.
    public let found: [OpenerApp]

    /// The apps in the user's list, in the order the menu shows them.
    public private(set) var choices: [OpenerApp] = []

    /// Whether the setting is on another app, with the second dropdown revealed.
    ///
    /// The list only holds the apps somebody added, so the app they want to open folders
    /// in may not be in it yet. Asking for another one reveals every app this mac can
    /// open a folder with, and taking one from there adds it to the list on the way.
    public private(set) var isOther = false

    /// What the mac finds the app taken under ``isOther`` by, empty while none is.
    public private(set) var otherBundleIdentifier = ""

    /// The store the apps are kept in, which taking another app writes into.
    @ObservationIgnored public let list: RecordStore<AppList>

    @ObservationIgnored private var listSubscription: StoreSubscription?
    @ObservationIgnored private var storeSubscription: StoreSubscription?

    private var picked: AppIdentifier?

    /// Builds the setting's model and starts following both stores.
    ///
    /// - Parameters:
    ///   - list: The one copy of the apps.
    ///   - store: The one copy of the choices the app remembers.
    ///   - found: The apps this mac can open a folder with.
    public init(
        list: RecordStore<AppList>,
        store: RecordStore<Preferences>,
        found: [OpenerApp]
    ) {
        self.list = list
        self.store = store
        self.found = found
        listSubscription = list.subscribe { [weak self] list in
            self?.choices = list.apps
        }
        storeSubscription = store.subscribe { [weak self] preferences in
            self?.picked = preferences.defaultAppId
        }
    }

    /// The app a folder opens in by default, or `nil` when none is picked.
    ///
    /// An app that is no longer in the list answers `nil`, because a default nobody can
    /// see is the same as no default at all.
    public var defaultAppId: AppIdentifier? {
        guard let picked, choices.contains(where: { $0.id == picked }) else { return nil }
        return picked
    }

    /// Whether this app is the one a folder opens in by default.
    ///
    /// - Parameter id: The app to ask about.
    /// - Returns: `true` when it is the default.
    public func isDefault(_ id: AppIdentifier) -> Bool {
        defaultAppId == id
    }

    /// Picks the app a folder opens in by default, out of the ones in the list.
    ///
    /// An app that is not in the list is ignored, so a stale pick cannot be saved.
    ///
    /// - Parameter id: The app to open folders in.
    public func choose(_ id: AppIdentifier) {
        guard choices.contains(where: { $0.id == id }) else { return }
        putOtherAway()
        write(id)
    }

    /// Picks no default at all, which is allowed and leaves nothing marked.
    public func clear() {
        putOtherAway()
        write(nil)
    }

    /// Reveals the apps this mac can open a folder with, beyond the ones in the list.
    public func useOther() {
        isOther = true
    }

    /// Takes an app picked under ``isOther``, adding it to the list if it is new.
    ///
    /// Somebody picking an app here has said they want folders opening in it, and the
    /// menu can only offer an app the list holds, so it goes in the list as well. An
    /// app already in the list keeps its place and its id rather than joining twice.
    ///
    /// - Parameter app: What the app calls itself and what the mac finds it by.
    public func take(_ app: FoundApp) {
        otherBundleIdentifier = app.bundleIdentifier
        guard let id = identifier(for: app) else { return }
        write(id)
    }

    private func identifier(for app: FoundApp) -> AppIdentifier? {
        let already = list.value.apps.first { $0.bundleIdentifier == app.bundleIdentifier }
        guard already == nil else { return already?.id }

        guard let id = AppSuggestion.identifier(
            fromBundleIdentifier: app.bundleIdentifier,
            avoiding: Set(list.value.apps.map(\.id))
        ) else { return nil }

        let added = OpenerApp(
            id: id,
            displayName: app.displayName,
            bundleIdentifier: app.bundleIdentifier
        )
        try? list.save(list.value.adding(added))
        return id
    }

    private func putOtherAway() {
        isOther = false
        otherBundleIdentifier = ""
    }

    private func write(_ id: AppIdentifier?) {
        try? store.save(store.value.defaulting(to: id))
    }
}
