import Testing

@testable import OpenFolderInCore

@Suite("App suggestion")
struct AppSuggestionTests {

    @Test("Names an app after the last part of its bundle name")
    func namesAfterTheLastPart() {
        #expect(AppSuggestion.name(fromBundleIdentifier: "com.microsoft.VSCode") == "vscode")
    }

    @Test("Turns anything an id cannot hold into a hyphen")
    func replacesWhatIdsCannotHold() {
        #expect(AppSuggestion.name(fromBundleIdentifier: "com.example.My App") == "my-app")
    }

    @Test("A bundle name with no parts is used whole")
    func singlePartIsUsedWhole() {
        #expect(AppSuggestion.name(fromBundleIdentifier: "Terminal") == "terminal")
    }

    @Test("A bundle name that turns into nothing falls back to something usable")
    func unusableBundleNameFallsBack() {
        #expect(!AppSuggestion.name(fromBundleIdentifier: "...").isEmpty)
    }

    @Test("Builds an id in the namespace apps the user added belong to")
    func idIsInTheUserNamespace() throws {
        let id = try #require(
            AppSuggestion.identifier(fromBundleIdentifier: "com.apple.Terminal", avoiding: [])
        )

        #expect(id.namespace.hasPrefix(IdentifierConstants.userNamespacePrefix))
        #expect(id.name == "terminal")
    }

    @Test("Counts up rather than handing back an id already in use")
    func countsUpPastATakenId() throws {
        let first = try #require(
            AppSuggestion.identifier(fromBundleIdentifier: "com.apple.Terminal", avoiding: [])
        )

        let second = try #require(
            AppSuggestion.identifier(
                fromBundleIdentifier: "com.apple.Terminal",
                avoiding: [first]
            )
        )

        #expect(second != first)
        #expect(second.name.hasPrefix("terminal"))
    }
}
