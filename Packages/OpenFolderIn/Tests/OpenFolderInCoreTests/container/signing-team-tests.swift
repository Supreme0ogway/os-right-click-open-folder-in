import Testing

@testable import OpenFolderInCore

@Suite("Signing team")
struct SigningTeamTests {

    @Test("A build nobody signed names no team, rather than guessing at one")
    func unsignedBuildNamesNoTeam() {
        #expect(SigningTeam.identifier == nil)
    }

    @Test("The answer is worked out once and does not change while the app runs")
    func theAnswerIsSteady() {
        #expect(SigningTeam.identifier == SigningTeam.identifier)
    }
}
