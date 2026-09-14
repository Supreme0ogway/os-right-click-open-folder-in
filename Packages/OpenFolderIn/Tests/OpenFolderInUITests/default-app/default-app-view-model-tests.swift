import Foundation
import Testing

@testable import OpenFolderInUI

@Suite("Default app view model")
@MainActor
struct DefaultAppViewModelTests {

    private func makeApp(_ id: String, name: String) throws -> OpenerApp {
        OpenerApp(
            id: try AppIdentifier(id),
            displayName: name,
            bundleIdentifier: "com.example." + name.lowercased()
        )
    }

    private func makeModel(apps: [OpenerApp]) throws -> DefaultAppViewModel {
        try DefaultAppBench.makeModel(apps: apps, found: [])
    }

    @Test("Nothing is the default until somebody picks one")
    func nothingIsDefaultAtFirst() throws {
        let model = try makeModel(apps: [try makeApp("core:terminal", name: "Terminal")])

        #expect(model.defaultAppId == nil)
        #expect(!model.isDefault(try AppIdentifier("core:terminal")))
    }

    @Test("Offers the apps in the list to pick a default from")
    func offersTheAppsInTheList() throws {
        let model = try makeModel(apps: [
            try makeApp("core:terminal", name: "Terminal"),
            try makeApp("core:vscode", name: "Code"),
        ])

        #expect(model.choices.map(\.displayName) == ["Terminal", "Code"])
    }

    @Test("Picking a default writes it back through the store")
    func pickingWritesThroughTheStore() throws {
        let wanted = try AppIdentifier("core:terminal")
        let model = try makeModel(apps: [try makeApp("core:terminal", name: "Terminal")])

        model.choose(wanted)

        #expect(model.store.value.defaultAppId == wanted)
        #expect(model.isDefault(wanted))
    }

    @Test("Picking none leaves nothing marked, which is allowed")
    func pickingNoneClearsIt() throws {
        let wanted = try AppIdentifier("core:terminal")
        let model = try makeModel(apps: [try makeApp("core:terminal", name: "Terminal")])

        model.choose(wanted)
        model.clear()

        #expect(model.store.value.defaultAppId == nil)
    }

    @Test("Picking an app that is not in the list marks nothing")
    func pickingSomethingUnknownMarksNothing() throws {
        let model = try makeModel(apps: [try makeApp("core:terminal", name: "Terminal")])

        model.choose(try AppIdentifier("core:gone"))

        #expect(model.store.value.defaultAppId == nil)
    }

    @Test("A default whose app was removed is no longer shown as picked")
    func removedDefaultIsNotShownAsPicked() throws {
        let wanted = try AppIdentifier("core:terminal")
        let model = try makeModel(apps: [try makeApp("core:terminal", name: "Terminal")])
        model.choose(wanted)

        try model.list.save(AppList.empty)

        #expect(model.defaultAppId == nil)
        #expect(model.store.value.defaultAppId == wanted)
    }
}

@Suite("Default app view model other")
@MainActor
struct DefaultAppViewModelOtherTests {

    private func makeApp(_ id: String, name: String, bundle: String) throws -> OpenerApp {
        OpenerApp(id: try AppIdentifier(id), displayName: name, bundleIdentifier: bundle)
    }

    private func makeModel(apps: [OpenerApp]) throws -> DefaultAppViewModel {
        try DefaultAppBench.makeModel(
            apps: apps,
            found: [
                try makeApp("user.found:terminal", name: "Terminal", bundle: "com.apple.Terminal"),
                try makeApp("user.found:vscode", name: "Code", bundle: "com.microsoft.VSCode"),
            ]
        )
    }

    private var code: FoundApp {
        FoundApp(displayName: "Code", bundleIdentifier: "com.microsoft.VSCode")
    }

    @Test("Nothing is revealed until somebody asks for another app")
    func nothingIsRevealedAtFirst() throws {
        let model = try makeModel(apps: [])

        #expect(!model.isOther)
        #expect(model.otherBundleIdentifier.isEmpty)
    }

    @Test("Asking for another app reveals the apps this mac has")
    func askingRevealsWhatThisMacHas() throws {
        let model = try makeModel(apps: [])

        model.useOther()

        #expect(model.isOther)
        #expect(model.found.map(\.displayName) == ["Terminal", "Code"])
    }

    @Test("An app taken under Other that is not in the list is added to it")
    func takenAppIsAddedToTheList() throws {
        let model = try makeModel(apps: [])
        model.useOther()

        model.take(code)

        #expect(model.list.value.apps.map(\.bundleIdentifier) == ["com.microsoft.VSCode"])
    }

    @Test("An app taken under Other becomes the app folders open in")
    func takenAppBecomesTheDefault() throws {
        let model = try makeModel(apps: [])
        model.useOther()

        model.take(code)

        let added = try #require(model.list.value.apps.first)
        #expect(model.store.value.defaultAppId == added.id)
        #expect(model.isDefault(added.id))
    }

    @Test("An app taken under Other that is already in the list is not added twice")
    func takenAppAlreadyInTheListIsNotAddedTwice() throws {
        let existing = try makeApp("core:vscode", name: "Code", bundle: "com.microsoft.VSCode")
        let model = try makeModel(apps: [existing])
        model.useOther()

        model.take(code)

        #expect(model.list.value.apps.count == 1)
        #expect(model.store.value.defaultAppId == existing.id)
    }

    @Test("What was taken is what the revealed dropdown shows")
    func revealedDropdownShowsWhatWasTaken() throws {
        let model = try makeModel(apps: [])
        model.useOther()

        model.take(code)

        #expect(model.otherBundleIdentifier == "com.microsoft.VSCode")
        #expect(model.isOther)
    }

    @Test("A default can be picked this way even when the list is empty")
    func worksFromAnEmptyList() throws {
        let model = try makeModel(apps: [])

        model.useOther()
        model.take(code)

        #expect(!model.list.value.isEmpty)
        #expect(model.defaultAppId != nil)
    }

    @Test("Picking an app from the list again puts the revealed dropdown away")
    func pickingFromTheListPutsItAway() throws {
        let existing = try makeApp("core:terminal", name: "Terminal", bundle: "com.apple.Terminal")
        let model = try makeModel(apps: [existing])
        model.useOther()

        model.choose(existing.id)

        #expect(!model.isOther)
    }

    @Test("Picking none puts the revealed dropdown away")
    func pickingNonePutsItAway() throws {
        let model = try makeModel(apps: [])
        model.useOther()

        model.clear()

        #expect(!model.isOther)
    }

    @Test("An app taken off the disk that the dropdown does not offer still works")
    func takenAppFromTheDiskStillWorks() throws {
        let model = try makeModel(apps: [])
        model.useOther()

        model.take(FoundApp(displayName: "Editor", bundleIdentifier: "com.example.editor"))

        #expect(model.list.value.apps.map(\.displayName) == ["Editor"])
        #expect(model.store.value.defaultAppId != nil)
    }
}

/// Builds the model over two stores in a folder of its own, so no test sees another's.
@MainActor
enum DefaultAppBench {

    static func makeModel(apps: [OpenerApp], found: [OpenerApp]) throws -> DefaultAppViewModel {
        let folder = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let list = RecordStore(
            fileURL: folder.appending(path: "app-list.json"),
            fallback: AppList.empty
        )
        try list.save(AppList(apps: apps))

        let preferences = RecordStore(
            fileURL: folder.appending(path: "preferences.json"),
            fallback: Preferences.fallback
        )
        return DefaultAppViewModel(list: list, store: preferences, found: found)
    }
}
