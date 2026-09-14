import Foundation
import Testing

@testable import OpenFolderInShared

@Suite("App identifier")
struct AppIdentifierTests {

    @Test("Reads a namespace and a name either side of a colon")
    func readsNamespaceAndName() throws {
        let id = try AppIdentifier("core:vscode")

        #expect(id.namespace == "core")
        #expect(id.name == "vscode")
    }

    @Test("Writes back out exactly the way it was written in")
    func writesBackOut() throws {
        #expect(try AppIdentifier("user.will:my-editor").text == "user.will:my-editor")
    }

    @Test("Refuses text with no separator")
    func refusesNoSeparator() {
        #expect(throws: AppIdentifierError.missingSeparator) {
            try AppIdentifier("vscode")
        }
    }

    @Test("Refuses text with two separators")
    func refusesTwoSeparators() {
        #expect(throws: AppIdentifierError.missingSeparator) {
            try AppIdentifier("core:vscode:extra")
        }
    }

    @Test("Refuses nothing before the separator")
    func refusesEmptyNamespace() {
        #expect(throws: AppIdentifierError.emptyNamespace) {
            try AppIdentifier(":vscode")
        }
    }

    @Test("Refuses nothing after the separator")
    func refusesEmptyName() {
        #expect(throws: AppIdentifierError.emptyName) {
            try AppIdentifier("core:")
        }
    }

    @Test("Refuses a character ids do not allow")
    func refusesBadCharacter() {
        #expect(throws: AppIdentifierError.invalidCharacter) {
            try AppIdentifier("core:vs code")
        }
    }

    @Test("Allows a dot in the namespace, so a user namespace can be named")
    func allowsDotInNamespace() throws {
        #expect(try AppIdentifier("user.will:editor").namespace == "user.will")
    }

    @Test("Refuses a dot in the name, which is the namespace's mark")
    func refusesDotInName() {
        #expect(throws: AppIdentifierError.invalidCharacter) {
            try AppIdentifier("core:vs.code")
        }
    }

    @Test("Reads back out of JSON as the plain string it was written as")
    func readsBackOutOfJSON() throws {
        let written = try JSONEncoder().encode(try AppIdentifier("core:terminal"))

        #expect(String(decoding: written, as: UTF8.self) == "\"core:terminal\"")
        #expect(try JSONDecoder().decode(AppIdentifier.self, from: written).name == "terminal")
    }

    @Test("Refuses to read a malformed id rather than carrying it")
    func refusesMalformedJSON() {
        let written = Data("\"not-an-id\"".utf8)

        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(AppIdentifier.self, from: written)
        }
    }

    @Test("Sorts by namespace, then by name, so a written list has a stable order")
    func sortsByNamespaceThenName() throws {
        let sorted = [
            try AppIdentifier("user.will:zed"),
            try AppIdentifier("core:terminal"),
            try AppIdentifier("core:aqua"),
        ].sorted()

        #expect(sorted.map(\.text) == ["core:aqua", "core:terminal", "user.will:zed"])
    }
}
