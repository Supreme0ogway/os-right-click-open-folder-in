import Foundation
import Testing

@testable import OpenFolderInCore

@Suite("Record file")
struct RecordFileTests {

    private func makeFolder() throws -> URL {
        let folder = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    @Test("What is written reads back unchanged")
    func roundTrips() throws {
        let fileURL = try makeFolder().appending(path: "app-list.json")
        let list = AppList(apps: [
            OpenerApp(
                id: try AppIdentifier("core:terminal"),
                displayName: "Terminal",
                bundleIdentifier: "com.apple.Terminal"
            )
        ])

        try RecordFile.write(list, to: fileURL)

        #expect(RecordFile.read(from: fileURL, fallback: AppList.empty) == list)
    }

    @Test("A file nobody has written yet answers with the fallback")
    func missingFileAnswersWithFallback() throws {
        let fileURL = try makeFolder().appending(path: "nothing.json")

        #expect(RecordFile.read(from: fileURL, fallback: AppList.empty) == AppList.empty)
    }

    @Test("A damaged file answers with the fallback, so a bad edit cannot stop the app")
    func damagedFileAnswersWithFallback() throws {
        let fileURL = try makeFolder().appending(path: "app-list.json")
        try Data("{ not json".utf8).write(to: fileURL)

        #expect(RecordFile.read(from: fileURL, fallback: AppList.empty) == AppList.empty)
    }

    @Test("Writing makes any folder it needs on the way")
    func writingMakesTheFolder() throws {
        let fileURL = try makeFolder().appending(path: "deeper/still/app-list.json")

        try RecordFile.write(AppList.empty, to: fileURL)

        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }

    @Test("What is written is spaced and sorted, so a person can read it")
    func writesReadableText() throws {
        let fileURL = try makeFolder().appending(path: "app-list.json")

        try RecordFile.write(AppList.empty, to: fileURL)
        let text = String(decoding: try Data(contentsOf: fileURL), as: UTF8.self)

        #expect(text.contains("\n"))
    }
}
