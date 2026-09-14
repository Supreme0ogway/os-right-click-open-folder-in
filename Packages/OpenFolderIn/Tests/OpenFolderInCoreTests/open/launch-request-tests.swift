import Foundation
import Testing

@testable import OpenFolderInCore

@Suite("Launch request")
struct LaunchRequestTests {

    private func makeRequest() throws -> LaunchRequest {
        LaunchRequest(appId: try AppIdentifier("core:vscode"), folderPath: "/Users/someone/Code")
    }

    @Test("Writes itself as an address and reads back the same way")
    func roundTrips() throws {
        let request = try makeRequest()

        #expect(LaunchRequest(url: request.url) == request)
    }

    @Test("The address names the app and the folder")
    func addressNamesBothParts() throws {
        let text = try makeRequest().url.absoluteString

        #expect(text.contains("core:vscode") || text.contains("core%3Avscode"))
        #expect(text.contains("Code"))
    }

    @Test("Refuses an address belonging to something else")
    func refusesAnotherScheme() {
        #expect(LaunchRequest(url: URL(string: "https://example.com/open?app=core:x")!) == nil)
    }

    @Test("Refuses an address asking for something this app does not do")
    func refusesAnotherAction() {
        #expect(LaunchRequest(url: URL(string: "open-folder-in://delete?app=core:x&folder=/a")!)
            == nil)
    }

    @Test("Refuses an address naming no app")
    func refusesMissingApp() {
        #expect(LaunchRequest(url: URL(string: "open-folder-in://open?folder=/a")!) == nil)
    }

    @Test("Refuses an address naming no folder")
    func refusesMissingFolder() {
        #expect(LaunchRequest(url: URL(string: "open-folder-in://open?app=core:x")!) == nil)
    }

    @Test("Refuses an app that is not a well formed id, rather than guessing at it")
    func refusesMalformedApp() {
        #expect(LaunchRequest(url: URL(string: "open-folder-in://open?app=nope&folder=/a")!) == nil)
    }

    @Test("Refuses a folder that is not an absolute path")
    func refusesRelativeFolder() {
        let url = URL(string: "open-folder-in://open?app=core:x&folder=Code")!

        #expect(LaunchRequest(url: url) == nil)
    }

    @Test("Keeps a folder whose name holds a space")
    func keepsSpaceInFolderName() throws {
        let request = LaunchRequest(
            appId: try AppIdentifier("core:vscode"),
            folderPath: "/Users/someone/My Code"
        )

        #expect(LaunchRequest(url: request.url)?.folderPath == "/Users/someone/My Code")
    }
}
