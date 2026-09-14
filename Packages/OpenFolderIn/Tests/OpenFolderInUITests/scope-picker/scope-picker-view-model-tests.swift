import Foundation
import Testing

@testable import OpenFolderInUI

@Suite("Scope picker view model")
@MainActor
struct ScopePickerViewModelTests {

    private func makeStore() throws -> RecordStore<Scope> {
        let folder = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return RecordStore(fileURL: folder.appending(path: "scope.json"), fallback: .fallback)
    }

    @Test("Starts watching everywhere, which is what a first launch does")
    func startsEverywhere() throws {
        #expect(ScopePickerViewModel(store: try makeStore()).isEverywhere)
    }

    @Test("Switching to picked folders starts with none chosen")
    func switchingStartsWithNoFolders() throws {
        let model = ScopePickerViewModel(store: try makeStore())

        model.usePickedFolders()

        #expect(!model.isEverywhere)
        #expect(model.folderPaths.isEmpty)
    }

    @Test("Switching to picked folders twice does not throw away what was chosen")
    func switchingTwiceKeepsTheFolders() throws {
        let model = ScopePickerViewModel(store: try makeStore())
        model.usePickedFolders()
        model.addFolder(URL(filePath: "/Users/someone/Code"))

        model.usePickedFolders()

        #expect(model.folderPaths == ["/Users/someone/Code"])
    }

    @Test("Adding a folder writes it back through the store")
    func addingWritesThroughTheStore() throws {
        let store = try makeStore()
        let model = ScopePickerViewModel(store: store)

        model.addFolder(URL(filePath: "/Users/someone/Code"))

        #expect(store.value.folderPaths == ["/Users/someone/Code"])
    }

    @Test("Removing the last folder leaves the menu nowhere, and says so")
    func removingTheLastFolderWarns() throws {
        let model = ScopePickerViewModel(store: try makeStore())
        model.addFolder(URL(filePath: "/Users/someone/Code"))

        model.removeFolder("/Users/someone/Code")

        #expect(model.showsNowhereWarning)
    }

    @Test("Watching everywhere is never watching nowhere")
    func everywhereNeverWarns() throws {
        #expect(!ScopePickerViewModel(store: try makeStore()).showsNowhereWarning)
    }

    @Test("Going back to everywhere clears the warning")
    func goingBackClearsTheWarning() throws {
        let model = ScopePickerViewModel(store: try makeStore())
        model.usePickedFolders()

        model.useEverywhere()

        #expect(model.isEverywhere)
        #expect(!model.showsNowhereWarning)
    }
}
