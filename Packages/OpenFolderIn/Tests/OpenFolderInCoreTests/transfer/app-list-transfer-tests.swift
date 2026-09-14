import Foundation
import Testing

@testable import OpenFolderInCore

@Suite("App list transfer")
struct AppListTransferTests {

    private func makeApp(_ id: String, name: String) throws -> OpenerApp {
        OpenerApp(
            id: try AppIdentifier(id),
            displayName: name,
            bundleIdentifier: "com.example." + name.lowercased()
        )
    }

    @Test("What is written out reads back in unchanged")
    func roundTrips() throws {
        let list = AppList(apps: [try makeApp("core:terminal", name: "Terminal")])

        let written = try AppListTransfer.data(for: list)

        #expect(try AppListTransfer.list(from: written) == list)
    }

    @Test("What is written out can be read by a person")
    func writesReadableText() throws {
        let list = AppList(apps: [try makeApp("core:terminal", name: "Terminal")])

        let text = String(decoding: try AppListTransfer.data(for: list), as: UTF8.self)

        #expect(text.contains("\n"))
        #expect(text.contains("Terminal"))
    }

    @Test("A file that is not a list of apps is refused rather than half read")
    func refusesSomethingElse() {
        #expect(throws: AppListTransferError.cannotBeRead) {
            try AppListTransfer.list(from: Data("not json at all".utf8))
        }
    }

    @Test("Bringing a list in adds to the one already there")
    func bringingInAdds() throws {
        let existing = AppList(apps: [try makeApp("core:terminal", name: "Terminal")])
        let incoming = AppList(apps: [try makeApp("core:vscode", name: "Code")])

        let joined = AppListTransfer.joining(incoming, into: existing)

        #expect(joined.apps.map(\.id.text) == ["core:terminal", "core:vscode"])
    }

    @Test("An app that came in under a known id takes its place and keeps it")
    func sharedIdKeepsItsPlace() throws {
        let existing = AppList(apps: [
            try makeApp("core:terminal", name: "Terminal"),
            try makeApp("core:vscode", name: "Code"),
        ])
        let incoming = AppList(apps: [try makeApp("core:terminal", name: "Renamed")])

        let joined = AppListTransfer.joining(incoming, into: existing)

        #expect(joined.apps.map(\.displayName) == ["Renamed", "Code"])
    }

    @Test("Bringing the same file in twice changes nothing the second time")
    func bringingInTwiceIsTheSame() throws {
        let existing = AppList(apps: [try makeApp("core:terminal", name: "Terminal")])
        let incoming = AppList(apps: [try makeApp("core:vscode", name: "Code")])

        let once = AppListTransfer.joining(incoming, into: existing)

        #expect(AppListTransfer.joining(incoming, into: once) == once)
    }

    @Test("A written out file has a name to suggest")
    func suggestsAFileName() {
        #expect(AppListTransfer.suggestedFileName.hasSuffix(".json"))
    }
}
