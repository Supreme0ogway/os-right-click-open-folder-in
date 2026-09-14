import Testing

@testable import OpenFolderInCore

@Suite("Shared container")
struct SharedContainerTests {

    @Test("An unsigned build has no shared folder, which is a build problem not a crash")
    func unsignedBuildHasNoFolder() {
        #expect(SharedContainer.folderURL == nil)
        #expect(SharedContainer.appListFileURL == nil)
        #expect(SharedContainer.scopeFileURL == nil)
        #expect(SharedContainer.preferencesFileURL == nil)
        #expect(SharedContainer.trailFileURL == nil)
    }

    @Test("Nothing can be written to a folder that was never given out")
    func unsignedBuildCannotBeWrittenTo() {
        #expect(!SharedContainer.canBeWrittenTo())
    }

    @Test("Each file has its own name, so two records never land in one file")
    func everyRecordHasItsOwnFileName() {
        let names = [
            AppListConstants.fileName,
            ScopeConstants.fileName,
            PreferencesConstants.fileName,
            TrailConstants.fileName,
        ]

        #expect(Set(names).count == names.count)
    }
}
