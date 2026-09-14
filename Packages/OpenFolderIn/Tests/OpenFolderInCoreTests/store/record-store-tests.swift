import Foundation
import Testing

@testable import OpenFolderInCore

@Suite("Record store")
@MainActor
struct RecordStoreTests {

    private func makeFileURL() throws -> URL {
        let folder = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appending(path: "app-list.json")
    }

    private func makeList(_ name: String) throws -> AppList {
        AppList(apps: [
            OpenerApp(
                id: try AppIdentifier("core:terminal"),
                displayName: name,
                bundleIdentifier: "com.apple.Terminal"
            )
        ])
    }

    @Test("A store nobody has saved to answers like an empty one")
    func emptyStoreAnswersWithFallback() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: AppList.empty)

        #expect(store.value == AppList.empty)
    }

    @Test("A new subscriber is told what the record says straight away")
    func subscriberIsToldAtOnce() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: AppList.empty)
        var heard: [AppList] = []

        let subscription = store.subscribe { heard.append($0) }

        #expect(heard == [AppList.empty])
        subscription.cancel()
    }

    @Test("Saving tells every subscriber")
    func savingTellsEverySubscriber() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: AppList.empty)
        var first: [AppList] = []
        var second: [AppList] = []
        let one = store.subscribe { first.append($0) }
        let two = store.subscribe { second.append($0) }

        try store.save(try makeList("Terminal"))

        #expect(first.count == 2)
        #expect(second.count == 2)
        one.cancel()
        two.cancel()
    }

    @Test("Saving the same thing again tells nobody, so nothing redraws for no reason")
    func savingTheSameTellsNobody() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: AppList.empty)
        var heard: [AppList] = []
        let subscription = store.subscribe { heard.append($0) }

        try store.save(AppList.empty)

        #expect(heard.count == 1)
        subscription.cancel()
    }

    @Test("What was saved is on disk for the Finder extension to read")
    func savedRecordIsOnDisk() throws {
        let fileURL = try makeFileURL()
        let store = RecordStore(fileURL: fileURL, fallback: AppList.empty)

        try store.save(try makeList("Terminal"))

        #expect(RecordFile.read(from: fileURL, fallback: AppList.empty) == store.value)
    }

    @Test("A store built on a file that was already written reads it")
    func readsWhatWasAlreadyThere() throws {
        let fileURL = try makeFileURL()
        try RecordFile.write(try makeList("Terminal"), to: fileURL)

        let store = RecordStore(fileURL: fileURL, fallback: AppList.empty)

        #expect(store.value == (try makeList("Terminal")))
    }

    @Test("Reading again picks up what another process wrote")
    func reloadPicksUpAnotherWriter() throws {
        let fileURL = try makeFileURL()
        let store = RecordStore(fileURL: fileURL, fallback: AppList.empty)
        try RecordFile.write(try makeList("Terminal"), to: fileURL)

        store.reload()

        #expect(store.value == (try makeList("Terminal")))
    }

    @Test("Reading again when nothing changed tells nobody")
    func reloadWithNoChangeTellsNobody() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: AppList.empty)
        var heard: [AppList] = []
        let subscription = store.subscribe { heard.append($0) }

        store.reload()

        #expect(heard.count == 1)
        subscription.cancel()
    }

    @Test("A subscriber that stopped is not told again")
    func cancelledSubscriberIsNotTold() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: AppList.empty)
        var heard: [AppList] = []
        let subscription = store.subscribe { heard.append($0) }

        subscription.cancel()
        try store.save(try makeList("Terminal"))

        #expect(heard.count == 1)
    }

    @Test("Stopping twice changes nothing")
    func cancellingTwiceIsFine() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: AppList.empty)
        let subscription = store.subscribe { _ in }

        subscription.cancel()
        subscription.cancel()

        #expect(store.subscriberCount == 0)
    }

    @Test("A subscriber that was let go of stops on its own, so nothing leaks")
    func droppedSubscriptionStops() throws {
        let store = RecordStore(fileURL: try makeFileURL(), fallback: AppList.empty)

        do {
            let subscription = store.subscribe { _ in }
            #expect(store.subscriberCount == 1)
            _ = subscription
        }

        #expect(store.subscriberCount == 0)
    }
}
