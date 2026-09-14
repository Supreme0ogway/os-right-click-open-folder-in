import Foundation
import Testing

@testable import OpenFolderInCore

@Suite("Installed apps")
struct InstalledAppsTests {

    @Test("The Finder can open a folder, so it is always one of the answers")
    func finderIsAlwaysOffered() {
        let identifiers = InstalledApps.thatCanOpenFolders().map(\.bundleIdentifier)

        #expect(identifiers.contains(DefaultsConstants.fallbackBundleIdentifier))
    }

    @Test("Every app it offers has its own id, so two never collide in the list")
    func everyOfferedAppHasItsOwnId() {
        let offered = InstalledApps.thatCanOpenFolders()

        #expect(Set(offered.map(\.id)).count == offered.count)
    }

    @Test("Every app it offers has something to show in the menu")
    func everyOfferedAppHasAName() {
        #expect(InstalledApps.thatCanOpenFolders().allSatisfy { !$0.displayName.isEmpty })
    }

    @Test("The apps it offers are sorted by name, so the list does not jump about")
    func offeredAppsAreSorted() {
        let names = InstalledApps.thatCanOpenFolders().map(\.displayName)

        #expect(names == names.sorted { $0.lowercased() < $1.lowercased() })
    }

    @Test("An app that is really on this mac is said to be installed")
    func realAppIsInstalled() {
        #expect(InstalledApps.isInstalled(DefaultsConstants.fallbackBundleIdentifier))
    }

    @Test("An app nobody has is not said to be installed")
    func inventedAppIsNotInstalled() {
        #expect(!InstalledApps.isInstalled("com.example.nothing-is-here"))
    }
}

@Suite("Found app")
struct FoundAppTests {

    private var finder: URL {
        get throws {
            try #require(
                InstalledApps.applicationURL(for: DefaultsConstants.fallbackBundleIdentifier)
            )
        }
    }

    @Test("An app picked off the disk gives up its name and what the mac finds it by")
    func realAppGivesUpBothParts() throws {
        let found = try #require(InstalledApps.found(at: try finder))

        #expect(found.bundleIdentifier == DefaultsConstants.fallbackBundleIdentifier)
        #expect(!found.displayName.isEmpty)
    }

    @Test("Something that is not an app gives nothing, rather than an empty entry")
    func aFolderIsNotAnApp() {
        #expect(InstalledApps.found(at: URL.temporaryDirectory) == nil)
    }

    @Test("A path with nothing at it gives nothing")
    func nothingThereGivesNothing() {
        let gone = URL.temporaryDirectory.appending(path: UUID().uuidString + ".app")

        #expect(InstalledApps.found(at: gone) == nil)
    }
}
