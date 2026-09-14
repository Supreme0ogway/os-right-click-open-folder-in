import Foundation
import Testing

@testable import OpenFolderInCore

@Suite("Request trail")
struct RequestTrailTests {

    @Test("Keeps what happened, so a click that never arrived can be told from one refused")
    func keepsWhatHappened() {
        let trail = RequestTrail(
            appId: "core:vscode",
            folderPath: "/Users/someone/Code",
            menuKind: 1,
            handedOver: false,
            note: "the app could not be opened"
        )

        #expect(trail.appId == "core:vscode")
        #expect(trail.folderPath == "/Users/someone/Code")
        #expect(!trail.handedOver)
        #expect(trail.note == "the app could not be opened")
    }

    @Test("Notes when the click happened, without being told")
    func notesWhenItHappened() {
        let trail = RequestTrail(
            appId: "core:vscode",
            folderPath: "/a",
            menuKind: 0,
            handedOver: true,
            note: ""
        )

        #expect(trail.when.timeIntervalSinceNow < 1)
    }

    @Test("Reads back out of JSON the way it went in, so a person can open the note")
    func readsBackOutOfJSON() throws {
        let trail = RequestTrail(
            appId: "core:vscode",
            folderPath: "/a",
            menuKind: 2,
            handedOver: true,
            note: ""
        )
        let written = try JSONEncoder().encode(trail)

        #expect(try JSONDecoder().decode(RequestTrail.self, from: written) == trail)
    }
}
