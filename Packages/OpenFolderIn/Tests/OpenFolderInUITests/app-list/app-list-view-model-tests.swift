import Foundation
import Testing

@testable import OpenFolderInUI

@Suite("App list view model")
@MainActor
struct AppListViewModelTests {

    private func makeApp(_ id: String, name: String) throws -> OpenerApp {
        OpenerApp(
            id: try AppIdentifier(id),
            displayName: name,
            bundleIdentifier: "com.example." + name.lowercased().replacingOccurrences(
                of: " ",
                with: "-"
            )
        )
    }

    private func makeStore(_ apps: [OpenerApp] = []) throws -> RecordStore<AppList> {
        let folder = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let store = RecordStore(
            fileURL: folder.appending(path: "app-list.json"),
            fallback: AppList.empty
        )
        try store.save(AppList(apps: apps))
        return store
    }

    @Test("Follows the store, so the screen and the menu cannot disagree")
    func followsTheStore() throws {
        let store = try makeStore([try makeApp("core:terminal", name: "Terminal")])

        let model = AppListViewModel(store: store)

        #expect(model.apps.map(\.displayName) == ["Terminal"])
    }

    @Test("Is told when the store changes underneath it")
    func hearsAboutAChange() throws {
        let store = try makeStore()
        let model = AppListViewModel(store: store)

        try store.save(AppList(apps: [try makeApp("core:terminal", name: "Terminal")]))

        #expect(model.apps.count == 1)
    }

    @Test("A blank search shows everything")
    func blankSearchShowsEverything() throws {
        let model = AppListViewModel(store: try makeStore([
            try makeApp("core:terminal", name: "Terminal"),
            try makeApp("core:vscode", name: "Visual Studio Code"),
        ]))

        #expect(model.shownApps.count == 2)
    }

    @Test("Searching finds an app by its name")
    func searchFindsByName() throws {
        let model = AppListViewModel(store: try makeStore([
            try makeApp("core:terminal", name: "Terminal"),
            try makeApp("core:vscode", name: "Visual Studio Code"),
        ]))

        model.search = "studio"

        #expect(model.shownApps.map(\.displayName) == ["Visual Studio Code"])
    }

    @Test("Searching finds an app by the name the mac knows it under")
    func searchFindsByBundleIdentifier() throws {
        let model = AppListViewModel(store: try makeStore([
            try makeApp("core:terminal", name: "Terminal"),
            try makeApp("core:vscode", name: "Visual Studio Code"),
        ]))

        model.search = "com.example.terminal"

        #expect(model.shownApps.map(\.displayName) == ["Terminal"])
    }

    @Test("An empty list says so, because an empty list is allowed")
    func emptyListSaysSo() throws {
        #expect(AppListViewModel(store: try makeStore()).showsEmptyMessage)
    }

    @Test("A search that matched nothing is said differently from an empty list")
    func noMatchesIsNotEmpty() throws {
        let model = AppListViewModel(store: try makeStore([
            try makeApp("core:terminal", name: "Terminal")
        ]))

        model.search = "nothing like this"

        #expect(model.showsNoMatchesMessage)
        #expect(!model.showsEmptyMessage)
    }

    @Test("Dragging is off while a search is showing only part of the list")
    func cannotReorderWhileSearching() throws {
        let model = AppListViewModel(store: try makeStore([
            try makeApp("core:terminal", name: "Terminal")
        ]))

        model.search = "term"

        #expect(!model.canReorder)
    }

    @Test("Moving an app writes the new order back through the store")
    func movingWritesThroughTheStore() throws {
        let store = try makeStore([
            try makeApp("core:one", name: "One"),
            try makeApp("core:two", name: "Two"),
        ])
        let model = AppListViewModel(store: store)

        model.move(from: IndexSet(integer: 1), to: 0)

        #expect(store.value.apps.map(\.displayName) == ["Two", "One"])
    }

    @Test("Moving does nothing while a search is showing only part of the list")
    func movingDoesNothingWhileSearching() throws {
        let store = try makeStore([
            try makeApp("core:one", name: "One"),
            try makeApp("core:two", name: "Two"),
        ])
        let model = AppListViewModel(store: store)
        model.search = "one"

        model.move(from: IndexSet(integer: 1), to: 0)

        #expect(store.value.apps.map(\.displayName) == ["One", "Two"])
    }

    @Test("Adding an app puts it in the store")
    func addingPutsItInTheStore() throws {
        let store = try makeStore()
        let model = AppListViewModel(store: store)

        model.add(try makeApp("core:terminal", name: "Terminal"))

        #expect(store.value.apps.count == 1)
    }

    @Test("Changing an app keeps its place in the list")
    func changingKeepsItsPlace() throws {
        let store = try makeStore([
            try makeApp("core:one", name: "One"),
            try makeApp("core:two", name: "Two"),
        ])
        let model = AppListViewModel(store: store)

        model.updateApp(try makeApp("core:one", name: "Renamed"))

        #expect(store.value.apps.map(\.displayName) == ["Renamed", "Two"])
    }

    @Test("Removing is asked about first, because it cannot be undone")
    func removingIsAskedAboutFirst() throws {
        let store = try makeStore([try makeApp("core:terminal", name: "Terminal")])
        let model = AppListViewModel(store: store)

        model.askToRemove(try AppIdentifier("core:terminal"))

        #expect(model.isAskingToRemove)
        #expect(model.pendingRemovalName == "Terminal")
        #expect(store.value.apps.count == 1)
    }

    @Test("Saying yes removes the app")
    func sayingYesRemovesIt() throws {
        let store = try makeStore([try makeApp("core:terminal", name: "Terminal")])
        let model = AppListViewModel(store: store)

        model.askToRemove(try AppIdentifier("core:terminal"))
        model.confirmRemoval()

        #expect(store.value.isEmpty)
        #expect(!model.isAskingToRemove)
    }

    @Test("Saying no leaves the app alone")
    func sayingNoLeavesItAlone() throws {
        let store = try makeStore([try makeApp("core:terminal", name: "Terminal")])
        let model = AppListViewModel(store: store)

        model.askToRemove(try AppIdentifier("core:terminal"))
        model.cancelRemoval()

        #expect(store.value.apps.count == 1)
        #expect(!model.isAskingToRemove)
    }

    @Test("Asking about an app that is not in the list asks nothing")
    func askingAboutAnUnknownAppAsksNothing() throws {
        let model = AppListViewModel(store: try makeStore())

        model.askToRemove(try AppIdentifier("core:gone"))

        #expect(!model.isAskingToRemove)
    }

    @Test("Replacing the whole list is what bringing one in from a file does")
    func replacingTheWholeList() throws {
        let store = try makeStore([try makeApp("core:one", name: "One")])
        let model = AppListViewModel(store: store)

        model.replaceAll(with: AppList(apps: [try makeApp("core:two", name: "Two")]))

        #expect(store.value.apps.map(\.displayName) == ["Two"])
    }
}
