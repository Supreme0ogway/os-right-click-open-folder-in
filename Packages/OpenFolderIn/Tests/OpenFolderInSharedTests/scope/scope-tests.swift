import Foundation
import Testing

@testable import OpenFolderInShared

@Suite("Scope")
struct ScopeTests {

    @Test("An app with nothing set up watches everywhere")
    func fallbackWatchesEverywhere() {
        #expect(Scope.fallback.places == .everywhere)
    }

    @Test("Watching everywhere watches no named folder")
    func everywhereNamesNoFolder() {
        #expect(Scope.everywhere.folderPaths.isEmpty)
    }

    @Test("Watching everywhere is never watching nothing")
    func everywhereIsNotNothing() {
        #expect(!Scope.everywhere.watchesNothing)
    }

    @Test("Picking folders and removing them all watches nothing, which is allowed")
    func noFoldersWatchesNothing() {
        #expect(Scope(places: .folders([])).watchesNothing)
    }

    @Test("Adding a folder to everywhere narrows it to that folder")
    func addingNarrowsEverywhere() {
        let narrowed = Scope.everywhere.addingFolder("/Users/someone/Code")

        #expect(narrowed.folderPaths == ["/Users/someone/Code"])
    }

    @Test("Takes a trailing slash off a folder, so one folder is never watched twice")
    func dropsTrailingSlash() {
        let scope = Scope(places: .folders(["/Users/someone/Code/", "/Users/someone/Code"]))

        #expect(scope.folderPaths == ["/Users/someone/Code"])
    }

    @Test("The top of the disk keeps its slash, being only a slash")
    func rootKeepsItsSlash() {
        #expect(Scope(places: .folders(["/"])).folderPaths == ["/"])
    }

    @Test("Drops a folder that was nothing but space")
    func dropsBlankFolder() {
        #expect(Scope(places: .folders(["   "])).folderPaths.isEmpty)
    }

    @Test("Removing a folder written with a trailing slash still finds it")
    func removingMatchesTidiedPath() {
        let scope = Scope(places: .folders(["/Users/someone/Code"]))

        #expect(scope.removingFolder("/Users/someone/Code/").folderPaths.isEmpty)
    }

    @Test("Removing a folder that is not there changes nothing")
    func removingUnknownChangesNothing() {
        let scope = Scope(places: .folders(["/Users/someone/Code"]))

        #expect(scope.removingFolder("/nowhere").folderPaths == ["/Users/someone/Code"])
    }

    @Test("Reads back out of JSON the way it went in")
    func readsBackOutOfJSON() throws {
        let scope = Scope(places: .folders(["/Users/someone/Code"]))
        let written = try JSONEncoder().encode(scope)

        #expect(try JSONDecoder().decode(Scope.self, from: written) == scope)
    }

    @Test("Anything unexpected in the file reads as everywhere, never as nowhere")
    func unexpectedReadsAsEverywhere() throws {
        let written = Data(#"{"version":1,"places":{"where":"something-else"}}"#.utf8)

        #expect(try JSONDecoder().decode(Scope.self, from: written).places == .everywhere)
    }

    @Test("A folders setting with no folders listed reads as no folders")
    func missingFolderListReadsAsEmpty() throws {
        let written = Data(#"{"version":1,"places":{"where":"folders"}}"#.utf8)

        #expect(try JSONDecoder().decode(Scope.self, from: written).watchesNothing)
    }
}
