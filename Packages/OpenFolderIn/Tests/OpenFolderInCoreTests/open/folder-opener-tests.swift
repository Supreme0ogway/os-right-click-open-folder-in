import Foundation
import Testing

@testable import OpenFolderInCore

@Suite("Folder opener")
struct FolderOpenerTests {

    private func makeApp(_ bundleIdentifier: String) throws -> OpenerApp {
        OpenerApp(
            id: try AppIdentifier("core:test"),
            displayName: "Test",
            bundleIdentifier: bundleIdentifier
        )
    }

    private func makeFolder() throws -> URL {
        let folder = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    @Test("A folder that is not there is refused before anything is launched")
    func missingFolderIsRefused() async throws {
        let gone = URL.temporaryDirectory.appending(path: UUID().uuidString)

        await #expect(throws: FolderOpenerError.folderIsMissing) {
            try await FolderOpener().open(gone, in: try makeApp("com.apple.Finder"))
        }
    }

    @Test("A file is not a folder, so opening one is refused")
    func fileIsRefused() async throws {
        let file = try makeFolder().appending(path: "notes.txt")
        try Data().write(to: file)

        await #expect(throws: FolderOpenerError.notAFolder) {
            try await FolderOpener().open(file, in: try makeApp("com.apple.Finder"))
        }
    }

    @Test("An app that was moved, renamed or removed is a state, not a crash")
    func missingAppIsRefused() async throws {
        let folder = try makeFolder()
        let missing = "com.example.nothing-is-here"

        await #expect(throws: FolderOpenerError.appIsNotInstalled(missing)) {
            try await FolderOpener().open(folder, in: try makeApp(missing))
        }
    }
}
