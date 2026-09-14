import Testing

@testable import OpenFolderInShared

@Suite("Bundle constants")
struct BundleConstantsTests {

    @Test("The extension's bundle name sits under the app's, which the system requires")
    func extensionSitsUnderTheApp() {
        #expect(BundleConstants.extensionIdentifier.hasPrefix(BundleConstants.appIdentifier))
    }

    @Test("The shared folder is named after the team that signed both halves")
    func sharedFolderCarriesTheTeam() {
        let name = BundleConstants.appGroupIdentifier(team: "ABCDE12345")

        #expect(name == "ABCDE12345.group." + BundleConstants.appIdentifier)
    }

    @Test("The address scheme holds nothing that would need escaping")
    func schemeIsPlain() {
        #expect(BundleConstants.urlScheme.allSatisfy { $0.isLowercase || $0 == "-" })
    }
}
