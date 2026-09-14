import Testing

@testable import OpenFolderInShared

@Suite("App check")
struct AppCheckTests {

    @Test("Takes the space off both ends of what was typed")
    func tidiesWhatWasTyped() {
        #expect(AppCheck.tidied("  Terminal  ") == "Terminal")
    }

    @Test("A name has to say something")
    func nameCannotBeEmpty() {
        #expect(AppCheck.nameProblem("   ") == .missing)
    }

    @Test("A name with words in it is fine")
    func nameWithWordsIsFine() {
        #expect(AppCheck.nameProblem("Visual Studio Code") == nil)
    }

    @Test("A bundle name has to say something")
    func bundleIdentifierCannotBeEmpty() {
        #expect(AppCheck.bundleIdentifierProblem("  ") == .missing)
    }

    @Test("A bundle name cannot hold a space")
    func bundleIdentifierCannotHoldSpace() {
        #expect(AppCheck.bundleIdentifierProblem("com.apple. Terminal") == .holdsSpace)
    }

    @Test("A bundle name cannot hold a slash")
    func bundleIdentifierCannotHoldSlash() {
        #expect(AppCheck.bundleIdentifierProblem("com/apple/Terminal") == .holdsPathCharacter)
    }

    @Test("A bundle name cannot hold a colon")
    func bundleIdentifierCannotHoldColon() {
        #expect(AppCheck.bundleIdentifierProblem("com:apple") == .holdsPathCharacter)
    }

    @Test("A bundle name needs a dot, because every real one has parts")
    func bundleIdentifierNeedsADot() {
        #expect(AppCheck.bundleIdentifierProblem("Terminal") == .missingDot)
    }

    @Test("A real bundle name is fine")
    func realBundleIdentifierIsFine() {
        #expect(AppCheck.bundleIdentifierProblem("com.microsoft.VSCode") == nil)
    }

    @Test("Space around a bundle name is never a fault, it is taken off")
    func spaceAroundBundleIdentifierIsFine() {
        #expect(AppCheck.bundleIdentifierProblem("  com.apple.Terminal ") == nil)
    }

    @Test("A bundle name past the limit is refused")
    func bundleIdentifierTooLong() {
        let long = "com." + String(repeating: "a", count: BundleIdentifierConstants.maximumLength)

        #expect(AppCheck.bundleIdentifierProblem(long) == .tooLong)
    }
}
