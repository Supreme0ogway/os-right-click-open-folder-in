import Foundation
import Testing

@testable import OpenFolderInShared

@Suite("Preferences")
struct PreferencesTests {

    @Test("An app with nothing set up has no default app picked")
    func fallbackHasNoDefault() {
        #expect(Preferences.fallback.defaultAppId == nil)
    }

    @Test("Remembers which app is the default")
    func remembersTheDefault() throws {
        let wanted = try AppIdentifier("core:vscode")

        #expect(Preferences.fallback.defaulting(to: wanted).defaultAppId == wanted)
    }

    @Test("Clearing the default leaves nothing picked")
    func clearingLeavesNothingPicked() throws {
        let picked = Preferences.fallback.defaulting(to: try AppIdentifier("core:vscode"))

        #expect(picked.defaulting(to: nil).defaultAppId == nil)
    }

    @Test("Keeps the shape it was written in when the default changes")
    func keepsItsVersion() throws {
        let changed = Preferences.fallback.defaulting(to: try AppIdentifier("core:vscode"))

        #expect(changed.version == PreferencesConstants.schemaVersion)
    }

    @Test("Reads back out of JSON the way it went in")
    func readsBackOutOfJSON() throws {
        let picked = Preferences.fallback.defaulting(to: try AppIdentifier("core:terminal"))
        let written = try JSONEncoder().encode(picked)

        #expect(try JSONDecoder().decode(Preferences.self, from: written) == picked)
    }

    @Test("A file with no default in it reads as nothing picked")
    func absentDefaultReadsAsNothing() throws {
        let written = Data(#"{"version":1}"#.utf8)

        #expect(try JSONDecoder().decode(Preferences.self, from: written).defaultAppId == nil)
    }
}
