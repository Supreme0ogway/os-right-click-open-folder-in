import Foundation
import Testing

@testable import OpenFolderInUI

@Suite("Transfer view model")
@MainActor
struct TransferViewModelTests {

    private func makeFolder() throws -> URL {
        let folder = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    private func makeApp(_ id: String, name: String) throws -> OpenerApp {
        OpenerApp(
            id: try AppIdentifier(id),
            displayName: name,
            bundleIdentifier: "com.example." + name.lowercased()
        )
    }

    private func makeStore(_ apps: [OpenerApp]) throws -> RecordStore<AppList> {
        let store = RecordStore(
            fileURL: try makeFolder().appending(path: "app-list.json"),
            fallback: AppList.empty
        )
        try store.save(AppList(apps: apps))
        return store
    }

    @Test("What is written out reads back in as the same list")
    func roundTrips() throws {
        let store = try makeStore([try makeApp("core:terminal", name: "Terminal")])
        let model = TransferViewModel(store: store)
        let destination = try makeFolder().appending(path: "apps.json")

        model.export(to: destination)

        #expect(model.problem == nil)
        #expect(try AppListTransfer.list(from: try Data(contentsOf: destination)) == store.value)
    }

    @Test("Bringing a file in adds to the list rather than replacing it")
    func bringingInAdds() throws {
        let store = try makeStore([try makeApp("core:terminal", name: "Terminal")])
        let model = TransferViewModel(store: store)
        let source = try makeFolder().appending(path: "apps.json")
        let incoming = AppList(apps: [try makeApp("core:vscode", name: "Code")])
        try AppListTransfer.data(for: incoming).write(to: source)

        model.importFrom(source)

        #expect(store.value.apps.map(\.displayName) == ["Terminal", "Code"])
    }

    @Test("A file that cannot be read leaves the list exactly as it was and says so")
    func damagedFileChangesNothing() throws {
        let store = try makeStore([try makeApp("core:terminal", name: "Terminal")])
        let model = TransferViewModel(store: store)
        let source = try makeFolder().appending(path: "apps.json")
        try Data("not json".utf8).write(to: source)

        model.importFrom(source)

        #expect(model.problem != nil)
        #expect(store.value.apps.count == 1)
    }

    @Test("A file that is not there says so rather than emptying the list")
    func missingFileChangesNothing() throws {
        let store = try makeStore([try makeApp("core:terminal", name: "Terminal")])
        let model = TransferViewModel(store: store)

        model.importFrom(try makeFolder().appending(path: "nothing.json"))

        #expect(model.problem != nil)
        #expect(store.value.apps.count == 1)
    }

    @Test("The message goes away when it is taken away")
    func messageCanBeCleared() throws {
        let model = TransferViewModel(store: try makeStore([]))
        model.importFrom(try makeFolder().appending(path: "nothing.json"))

        model.clearProblem()

        #expect(model.problem == nil)
    }

    @Test("A written out file has a name to suggest")
    func suggestsAFileName() throws {
        #expect(TransferViewModel(store: try makeStore([])).suggestedFileName.hasSuffix(".json"))
    }
}
