import Foundation
import Testing

@testable import OpenFolderInShared

@Suite("App list")
struct AppListTests {

    private func makeApp(_ id: String, name: String = "Terminal") throws -> OpenerApp {
        OpenerApp(
            id: try AppIdentifier(id),
            displayName: name,
            bundleIdentifier: "com.example." + name.lowercased()
        )
    }

    @Test("An empty list is a normal list, and means the menu shows nothing")
    func emptyIsNormal() {
        #expect(AppList.empty.isEmpty)
        #expect(AppList.empty.apps.isEmpty)
    }

    @Test("Keeps the apps in the order they were given, which is the menu's order")
    func keepsGivenOrder() throws {
        let list = AppList(apps: [
            try makeApp("core:terminal", name: "Terminal"),
            try makeApp("core:vscode", name: "Code"),
        ])

        #expect(list.apps.map(\.id.text) == ["core:terminal", "core:vscode"])
    }

    @Test("Drops a repeated id, keeping the first of each")
    func dropsRepeatedId() throws {
        let list = AppList(apps: [
            try makeApp("core:terminal", name: "Terminal"),
            try makeApp("core:terminal", name: "Second"),
        ])

        #expect(list.apps.count == 1)
        #expect(list.apps.first?.displayName == "Terminal")
    }

    @Test("Finds an app by its id")
    func findsAppById() throws {
        let list = AppList(apps: [try makeApp("core:terminal")])

        #expect(try list.app(withId: AppIdentifier("core:terminal")) != nil)
        #expect(try list.app(withId: AppIdentifier("core:vscode")) == nil)
    }

    @Test("A new app goes on the end")
    func newAppGoesOnTheEnd() throws {
        let list = AppList(apps: [try makeApp("core:terminal")])

        let grown = list.adding(try makeApp("core:vscode", name: "Code"))

        #expect(grown.apps.map(\.id.text) == ["core:terminal", "core:vscode"])
    }

    @Test("A known id keeps its place when it is changed")
    func knownIdKeepsItsPlace() throws {
        let list = AppList(apps: [
            try makeApp("core:terminal", name: "Terminal"),
            try makeApp("core:vscode", name: "Code"),
        ])

        let changed = list.adding(try makeApp("core:terminal", name: "Renamed"))

        #expect(changed.apps.map(\.displayName) == ["Renamed", "Code"])
    }

    @Test("Removing an app takes it out and leaves the rest alone")
    func removingTakesItOut() throws {
        let list = AppList(apps: [
            try makeApp("core:terminal"),
            try makeApp("core:vscode", name: "Code"),
        ])

        let smaller = list.removing(try AppIdentifier("core:terminal"))

        #expect(smaller.apps.map(\.id.text) == ["core:vscode"])
    }

    @Test("Removing an id that is not there changes nothing")
    func removingUnknownChangesNothing() throws {
        let list = AppList(apps: [try makeApp("core:terminal")])

        #expect(list.removing(try AppIdentifier("core:nothing")) == list)
    }

    @Test("Removing the last app is allowed and leaves an empty list")
    func removingTheLastIsAllowed() throws {
        let list = AppList(apps: [try makeApp("core:terminal")])

        #expect(list.removing(try AppIdentifier("core:terminal")).isEmpty)
    }

    @Test("Moving an app changes the order the menu shows")
    func movingChangesTheOrder() throws {
        let list = AppList(apps: [
            try makeApp("core:one", name: "One"),
            try makeApp("core:two", name: "Two"),
            try makeApp("core:three", name: "Three"),
        ])

        let moved = list.moving(from: [2], to: 0)

        #expect(moved.apps.map(\.displayName) == ["Three", "One", "Two"])
    }

    @Test("Moving nothing changes nothing")
    func movingNothingChangesNothing() throws {
        let list = AppList(apps: [try makeApp("core:one")])

        #expect(list.moving(from: [], to: 0) == list)
    }

    @Test("Moving from a place that is not there changes nothing")
    func movingFromNowhereChangesNothing() throws {
        let list = AppList(apps: [try makeApp("core:one")])

        #expect(list.moving(from: [7], to: 0) == list)
    }

    @Test("Carries the shape it was written in, so a later shape can be told apart")
    func carriesItsVersion() {
        #expect(AppList.empty.version == AppListConstants.schemaVersion)
    }

    @Test("Reads back out of JSON the way it went in")
    func readsBackOutOfJSON() throws {
        let list = AppList(apps: [try makeApp("core:terminal")])
        let written = try JSONEncoder().encode(list)

        #expect(try JSONDecoder().decode(AppList.self, from: written) == list)
    }
}
