import Testing

@testable import OpenFolderInUI

@Suite("Add app view model")
@MainActor
struct AddAppViewModelTests {

    private func makeApp(_ id: String, name: String, bundle: String) throws -> OpenerApp {
        OpenerApp(id: try AppIdentifier(id), displayName: name, bundleIdentifier: bundle)
    }

    private func makeChoices() throws -> [OpenerApp] {
        [
            try makeApp("user.found:terminal", name: "Terminal", bundle: "com.apple.Terminal"),
            try makeApp("user.found:vscode", name: "Code", bundle: "com.microsoft.VSCode"),
        ]
    }

    private func makeModel(taken: Set<AppIdentifier> = []) throws -> AddAppViewModel {
        AddAppViewModel(found: try makeChoices(), taken: taken)
    }

    @Test("Opens on the first app this mac has, so it is usable straight away")
    func opensOnTheFirstFoundApp() throws {
        let model = try makeModel()

        #expect(model.pickedBundleIdentifier == "com.apple.Terminal")
        #expect(model.name == "Terminal")
        #expect(model.isReady)
    }

    @Test("Opens ready for a typed name when this mac offered nothing")
    func opensOnCustomWhenNothingFound() {
        let model = AddAppViewModel(found: [], taken: [])

        #expect(model.isCustom)
        #expect(!model.isReady)
    }

    @Test("Picking an app fills the name in to match")
    func pickingFillsInTheName() throws {
        let model = try makeModel()

        model.pick("com.microsoft.VSCode")

        #expect(model.name == "Code")
        #expect(!model.isCustom)
    }

    @Test("Picking something this mac does not have changes nothing")
    func pickingSomethingUnknownChangesNothing() throws {
        let model = try makeModel()

        model.pick("com.example.nothing")

        #expect(model.pickedBundleIdentifier == "com.apple.Terminal")
    }

    @Test("Typing a name in empties the box, so nothing is added by accident")
    func typingEmptiesTheBox() throws {
        let model = try makeModel()

        model.useCustom()

        #expect(model.isCustom)
        #expect(model.customBundleIdentifier.isEmpty)
    }

    @Test("A typed bundle name is what the new app carries")
    func typedBundleNameIsUsed() throws {
        let model = try makeModel()

        model.useCustom()
        model.customBundleIdentifier = "com.example.editor"
        model.name = "Editor"

        #expect(model.build()?.bundleIdentifier == "com.example.editor")
    }

    @Test("Nothing is built while the name is empty")
    func nothingIsBuiltWithoutAName() throws {
        let model = try makeModel()

        model.name = "   "

        #expect(!model.isReady)
        #expect(model.build() == nil)
    }

    @Test("Nothing is built while the typed bundle name is not one")
    func nothingIsBuiltWithABadBundleName() throws {
        let model = try makeModel()

        model.useCustom()
        model.customBundleIdentifier = "not a bundle"
        model.name = "Editor"

        #expect(model.bundleIdentifierProblem == .holdsSpace)
        #expect(model.build() == nil)
    }

    @Test("The new app takes an id nothing in the list is already using")
    func newAppTakesAFreeId() throws {
        let existing = try AppIdentifier("user.found:terminal")
        let model = try makeModel(taken: [existing])

        #expect(model.build()?.id != existing)
    }

    @Test("An app chosen off the disk that the dropdown already offers is picked there")
    func chosenAppAlreadyOfferedIsPicked() throws {
        let model = try makeModel()

        model.use(FoundApp(displayName: "Code", bundleIdentifier: "com.microsoft.VSCode"))

        #expect(!model.isCustom)
        #expect(model.pickedBundleIdentifier == "com.microsoft.VSCode")
        #expect(model.name == "Code")
    }

    @Test("An app chosen off the disk that is new fills the typed box in")
    func chosenAppThatIsNewFillsTheBox() throws {
        let model = try makeModel()

        model.use(FoundApp(displayName: "Editor", bundleIdentifier: "com.example.editor"))

        #expect(model.isCustom)
        #expect(model.customBundleIdentifier == "com.example.editor")
        #expect(model.name == "Editor")
        #expect(model.isReady)
    }

    @Test("What was chosen off the disk is what the new app carries")
    func chosenAppIsWhatIsBuilt() throws {
        let model = try makeModel()

        model.use(FoundApp(displayName: "Editor", bundleIdentifier: "com.example.editor"))

        #expect(model.build()?.bundleIdentifier == "com.example.editor")
        #expect(model.build()?.displayName == "Editor")
    }

    @Test("Space around what was typed is taken off, never treated as a fault")
    func spaceIsTakenOff() throws {
        let model = try makeModel()

        model.useCustom()
        model.customBundleIdentifier = "  com.example.editor  "
        model.name = "  Editor  "

        #expect(model.build()?.displayName == "Editor")
        #expect(model.build()?.bundleIdentifier == "com.example.editor")
    }
}
