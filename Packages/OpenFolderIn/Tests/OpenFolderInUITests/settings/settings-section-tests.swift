import Testing

@testable import OpenFolderInUI

@Suite("Settings section")
struct SettingsSectionTests {

    @Test("Settings opens on what the app is, not on something to change")
    func opensOnAbout() {
        #expect(SettingsSection.opening == .about)
    }

    @Test("Every section has something to call it")
    func everySectionHasATitle() {
        #expect(SettingsSection.allCases.allSatisfy { !$0.title.isEmpty })
    }

    @Test("Every section has a symbol beside it")
    func everySectionHasASymbol() {
        #expect(SettingsSection.allCases.allSatisfy { !$0.iconName.isEmpty })
    }

    @Test("No two sections are called the same thing")
    func noTwoSectionsShareATitle() {
        #expect(Set(SettingsSection.allCases.map(\.title)).count == SettingsSection.allCases.count)
    }

    @Test("What tells one section from another is its own name")
    func idIsItsOwnName() {
        #expect(Set(SettingsSection.allCases.map(\.id)).count == SettingsSection.allCases.count)
    }
}
