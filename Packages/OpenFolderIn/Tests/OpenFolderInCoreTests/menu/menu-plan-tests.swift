import Foundation
import Testing

@testable import OpenFolderInCore

@Suite("Menu plan")
struct MenuPlanTests {

    private func makeApp(_ id: String, name: String) throws -> OpenerApp {
        OpenerApp(
            id: try AppIdentifier(id),
            displayName: name,
            bundleIdentifier: "com.example." + name.lowercased()
        )
    }

    private func makeList() throws -> AppList {
        AppList(apps: [
            try makeApp("core:terminal", name: "Terminal"),
            try makeApp("core:vscode", name: "Code"),
        ])
    }

    @Test("An empty list plans nothing at all, so the menu looks untouched")
    func emptyListPlansNothing() {
        #expect(MenuPlan.entries(for: AppList.empty, defaultAppId: nil).isEmpty)
    }

    @Test("Plans one entry for each app")
    func plansOneEntryPerApp() throws {
        let entries = MenuPlan.entries(for: try makeList(), defaultAppId: nil)

        #expect(entries.count == 2)
        #expect(entries.map(\.appId.text) == ["core:terminal", "core:vscode"])
    }

    @Test("Names an entry after the app it opens the folder in")
    func namesEntryAfterApp() throws {
        let entries = MenuPlan.entries(for: try makeList(), defaultAppId: nil)

        #expect(entries.first?.title == "Terminal")
    }

    @Test("Numbers the entries from zero, so a click can find its way back")
    func numbersEntriesFromZero() throws {
        #expect(MenuPlan.entries(for: try makeList(), defaultAppId: nil).map(\.place) == [0, 1])
    }

    @Test("Puts the default app first, the way the Finder's own Open With does")
    func defaultComesFirst() throws {
        let wanted = try AppIdentifier("core:vscode")

        let entries = MenuPlan.entries(for: try makeList(), defaultAppId: wanted)

        #expect(entries.map(\.appId.text) == ["core:vscode", "core:terminal"])
    }

    @Test("Marks the default app, so it is not just first for no visible reason")
    func defaultIsMarked() throws {
        let wanted = try AppIdentifier("core:vscode")

        let entries = MenuPlan.entries(for: try makeList(), defaultAppId: wanted)

        #expect(entries.first?.isDefault == true)
        #expect(entries.first?.title != "Code")
        #expect(entries.first?.title.contains("Code") == true)
        #expect(entries.last?.isDefault == false)
    }

    @Test("A default that is no longer in the list marks nothing and reorders nothing")
    func unknownDefaultChangesNothing() throws {
        let gone = try AppIdentifier("core:gone")

        let entries = MenuPlan.entries(for: try makeList(), defaultAppId: gone)

        #expect(entries.map(\.appId.text) == ["core:terminal", "core:vscode"])
        #expect(entries.allSatisfy { !$0.isDefault })
    }

    @Test("Finds the app a click came from by its number")
    func findsAppByNumber() throws {
        let found = MenuPlan.entry(at: 1, in: try makeList(), defaultAppId: nil)

        #expect(found?.appId.text == "core:vscode")
    }

    @Test("Finds the app a click came from once the default has moved the order")
    func findsAppByNumberWithDefaultFirst() throws {
        let wanted = try AppIdentifier("core:vscode")

        let found = MenuPlan.entry(at: 0, in: try makeList(), defaultAppId: wanted)

        #expect(found?.appId.text == "core:vscode")
    }

    @Test("Finds nothing when the list shrank between the menu opening and the click")
    func findsNothingWhenListShrank() throws {
        #expect(MenuPlan.entry(at: 9, in: try makeList(), defaultAppId: nil) == nil)
    }

    @Test("Finds nothing for a number below zero")
    func findsNothingBelowZero() throws {
        #expect(MenuPlan.entry(at: -1, in: try makeList(), defaultAppId: nil) == nil)
    }

    @Test("Says a menu with no entries should not be shown at all")
    func saysNothingToShow() {
        #expect(!MenuPlan.hasAnythingToShow(AppList.empty))
    }

    @Test("Says a menu with entries should be shown")
    func saysSomethingToShow() throws {
        #expect(MenuPlan.hasAnythingToShow(try makeList()))
    }

    @Test("The one entry added to the Finder's menu has something to say")
    func parentHasATitle() {
        #expect(!MenuPlan.parentTitle.isEmpty)
    }
}

@Suite("Menu plan folder")
struct MenuPlanFolderTests {

    private let folder = URL(filePath: "/Users/someone/Code", directoryHint: .isDirectory)
    private let file = URL(filePath: "/Users/someone/Code/notes.txt", directoryHint: .notDirectory)
    private let window = URL(filePath: "/Users/someone", directoryHint: .isDirectory)

    @Test("One clicked folder is the folder to open")
    func oneFolderIsTheAnswer() {
        #expect(MenuPlan.folderToOpen(selectedItems: [folder], container: window) == folder)
    }

    @Test("A clicked file is not a folder, so there is nothing to open")
    func fileIsNotAFolder() {
        #expect(MenuPlan.folderToOpen(selectedItems: [file], container: window) == nil)
    }

    @Test("Clicking the background of a window opens the folder that window shows")
    func backgroundOpensTheWindowsFolder() {
        #expect(MenuPlan.folderToOpen(selectedItems: [], container: window) == window)
    }

    @Test("Several folders at once is not one folder, so there is nothing to open")
    func severalFoldersIsNothing() {
        #expect(MenuPlan.folderToOpen(selectedItems: [folder, window], container: nil) == nil)
    }

    @Test("Nothing clicked and no window says nothing")
    func nothingAtAllIsNothing() {
        #expect(MenuPlan.folderToOpen(selectedItems: [], container: nil) == nil)
    }

    @Test("A window showing something that is not a folder says nothing")
    func fileAsContainerIsNothing() {
        #expect(MenuPlan.folderToOpen(selectedItems: [], container: file) == nil)
    }
}
