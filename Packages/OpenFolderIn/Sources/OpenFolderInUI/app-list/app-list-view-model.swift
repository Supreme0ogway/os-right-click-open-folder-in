import Foundation
import Observation

/// What the app list screen knows and can do.
///
/// Holds no copy of the apps. It follows the store, and every change it makes goes back
/// through the store, so the right click menu and this screen can never disagree about
/// what the list says.
///
/// Imports nothing to do with drawing, which is what lets the rules below be tested
/// without a screen.
@MainActor
@Observable
public final class AppListViewModel {

    /// The store this screen reads and writes. The only copy of the list.
    public let store: RecordStore<AppList>

    /// The apps, in the order they appear in the right click menu.
    public private(set) var apps: [OpenerApp] = []

    /// What has been typed into the search box.
    public var search = ""

    /// The last thing that went wrong, if anything did.
    public private(set) var problem: String?

    /// The app somebody has asked to remove, waiting to be told to go ahead.
    ///
    /// Removing an app cannot be undone, so it is asked about first. Both the list and
    /// the form ask through here, so the question is worded and answered in one place.
    public private(set) var pendingRemoval: AppIdentifier?

    @ObservationIgnored private var subscription: StoreSubscription?

    /// Builds the screen's model and starts following the store.
    ///
    /// - Parameter store: The one copy of the apps.
    public init(store: RecordStore<AppList>) {
        self.store = store
        subscription = store.subscribe { [weak self] list in
            self?.apps = list.apps
        }
    }

    /// The apps to show, once the search box has been taken into account.
    ///
    /// A blank search shows everything. Otherwise an app is shown when the search
    /// appears in its name or in the name the mac finds it by, so both "code" and
    /// "microsoft" find Visual Studio Code.
    public var shownApps: [OpenerApp] {
        let wanted = search.trimmed.lowercased()
        guard !wanted.isEmpty else { return apps }
        return apps.filter { matches($0, wanted) }
    }

    /// Whether to tell the user the list is empty.
    ///
    /// An empty list is allowed. It means the right click menu shows nothing at all,
    /// which the message explains so it does not look like a fault.
    public var showsEmptyMessage: Bool { apps.isEmpty }

    /// Whether the search found nothing, as opposed to there being nothing at all.
    public var showsNoMatchesMessage: Bool { !apps.isEmpty && shownApps.isEmpty }

    /// Whether the list can be dragged into a new order.
    ///
    /// Only while nothing is being searched for. A search shows part of the list, and
    /// dropping a row inside part of a list says nothing about where it belongs in
    /// the whole of it.
    public var canReorder: Bool { search.trimmed.isEmpty }

    /// Moves apps to a new place in the order, which is the order of the menu.
    ///
    /// - Parameters:
    ///   - offsets: Where the apps being moved are now.
    ///   - destination: Where they should land.
    public func move(from offsets: IndexSet, to destination: Int) {
        guard canReorder else { return }
        write(store.value.moving(from: Array(offsets), to: destination))
    }

    /// Puts an app built on the add screen into the list.
    ///
    /// - Parameter app: The app that was built.
    public func add(_ app: OpenerApp) {
        write(store.value.adding(app))
    }

    /// Saves a change to an app, keeping its place in the list.
    ///
    /// - Parameter app: The app as it now stands.
    public func updateApp(_ app: OpenerApp) {
        write(store.value.adding(app))
    }

    /// Removes an app.
    ///
    /// Removing the last one is allowed, and leaves the right click menu showing
    /// nothing at all.
    ///
    /// - Parameter id: The app to take out.
    public func removeApp(_ id: AppIdentifier) {
        write(store.value.removing(id))
    }

    /// Replaces the whole list, for when one is brought in from a file.
    ///
    /// - Parameter list: The list as it should now stand.
    public func replaceAll(with list: AppList) {
        write(list)
    }

    /// Whether the question about removing an app is being asked.
    public var isAskingToRemove: Bool { pendingRemoval != nil }

    /// What the app waiting to be removed is called, for the question to name it.
    public var pendingRemovalName: String {
        guard let pendingRemoval else { return "" }
        return apps.first { $0.id == pendingRemoval }?.displayName ?? ""
    }

    /// Asks whether an app should be removed, rather than removing it.
    ///
    /// - Parameter id: The app somebody wants to take out.
    public func askToRemove(_ id: AppIdentifier) {
        guard apps.contains(where: { $0.id == id }) else { return }
        pendingRemoval = id
    }

    /// Removes the app that was asked about.
    public func confirmRemoval() {
        guard let pendingRemoval else { return }
        removeApp(pendingRemoval)
        self.pendingRemoval = nil
    }

    /// Leaves the app alone and stops asking.
    public func cancelRemoval() {
        pendingRemoval = nil
    }

    private func matches(_ app: OpenerApp, _ wanted: String) -> Bool {
        app.displayName.lowercased().contains(wanted)
            || app.bundleIdentifier.lowercased().contains(wanted)
    }

    private func write(_ list: AppList) {
        do {
            try store.save(list)
            problem = nil
        } catch {
            problem = error.localizedDescription
        }
    }
}
