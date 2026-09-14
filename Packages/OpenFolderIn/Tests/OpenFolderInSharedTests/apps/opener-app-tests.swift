import Foundation
import Testing

@testable import OpenFolderInShared

@Suite("Opener app")
struct OpenerAppTests {

    private func makeApp(
        name: String = "Terminal",
        bundleIdentifier: String = "com.apple.Terminal"
    ) throws -> OpenerApp {
        OpenerApp(
            id: try AppIdentifier("core:terminal"),
            displayName: name,
            bundleIdentifier: bundleIdentifier
        )
    }

    @Test("Keeps what it was given")
    func keepsWhatItWasGiven() throws {
        let app = try makeApp()

        #expect(app.displayName == "Terminal")
        #expect(app.bundleIdentifier == "com.apple.Terminal")
    }

    @Test("Takes the space off the bundle name, so no lookup ever misses by a blank")
    func tidiesBundleIdentifier() throws {
        #expect(try makeApp(bundleIdentifier: "  com.apple.Terminal  ").bundleIdentifier
            == "com.apple.Terminal")
    }

    @Test("Takes the space off the name")
    func tidiesDisplayName() throws {
        #expect(try makeApp(name: "  Terminal  ").displayName == "Terminal")
    }

    @Test("A name that was nothing but space falls back to the bundle name")
    func blankNameFallsBackToBundleIdentifier() throws {
        #expect(try makeApp(name: "   ").displayName == "com.apple.Terminal")
    }

    @Test("Two apps with the same id are the same app")
    func sameIdIsTheSameApp() throws {
        #expect(try makeApp() == (try makeApp()))
    }

    @Test("Reads back out of JSON the way it went in")
    func readsBackOutOfJSON() throws {
        let app = try makeApp()
        let written = try JSONEncoder().encode(app)

        #expect(try JSONDecoder().decode(OpenerApp.self, from: written) == app)
    }
}
