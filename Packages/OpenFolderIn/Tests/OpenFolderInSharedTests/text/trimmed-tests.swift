import Testing

@testable import OpenFolderInShared

@Suite("Trimmed")
struct TrimmedTests {

    @Test("Takes space off the front")
    func takesSpaceOffTheFront() {
        #expect("   Terminal".trimmed == "Terminal")
    }

    @Test("Takes space off the back")
    func takesSpaceOffTheBack() {
        #expect("Terminal   ".trimmed == "Terminal")
    }

    @Test("Keeps space in the middle, because that is part of what was typed")
    func keepsSpaceInTheMiddle() {
        #expect("  Visual Studio Code  ".trimmed == "Visual Studio Code")
    }

    @Test("Text that is nothing but space comes back empty")
    func onlySpaceComesBackEmpty() {
        #expect("  \t\n ".trimmed.isEmpty)
    }

    @Test("Text with nothing around it is unchanged")
    func cleanTextIsUnchanged() {
        #expect("Terminal".trimmed == "Terminal")
    }

    @Test("Empty text stays empty")
    func emptyStaysEmpty() {
        #expect("".trimmed.isEmpty)
    }
}
