import Testing

@testable import OpenFolderInCore

@Suite("Changelog")
struct ChangelogTests {

    @Test("The shipped changelog can be read")
    func shippedChangelogLoads() {
        #expect(!Changelog.load().releases.isEmpty)
    }

    @Test("The newest release is the first one, which is what the about screen shows")
    func latestIsTheFirst() {
        let changelog = Changelog.load()

        #expect(changelog.latest == changelog.releases.first)
    }

    @Test("A changelog with no releases has no newest one")
    func noReleasesHasNoLatest() {
        #expect(Changelog(version: 1, releases: []).latest == nil)
    }

    @Test("Every release says what changed")
    func everyReleaseSaysWhatChanged() {
        #expect(Changelog.load().releases.allSatisfy { !$0.notes.isEmpty })
    }

    @Test("Every release says which version it was")
    func everyReleaseHasAVersion() {
        #expect(Changelog.load().releases.allSatisfy { !$0.version.isEmpty })
    }
}
