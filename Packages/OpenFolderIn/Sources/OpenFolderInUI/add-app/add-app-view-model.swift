import Observation

/// What the add screen knows and can do.
///
/// An app is either one this mac can already open a folder with, picked from a list, or
/// one whose bundle name is typed in. Either way it is not finished until it has a name
/// and a bundle name.
///
/// Imports nothing to do with drawing, so every rule below is covered by the ordinary
/// test run.
@MainActor
@Observable
public final class AddAppViewModel {

    /// The apps this mac can already open a folder with.
    public let choices: [OpenerApp]

    /// The bundle name picked from the list. Ignored while one is being typed.
    public private(set) var pickedBundleIdentifier: String

    /// Whether a bundle name is being typed in rather than picked.
    public private(set) var isCustom: Bool

    /// The bundle name being typed in. Only used while ``isCustom`` is true.
    public var customBundleIdentifier = ""

    /// What the entry will say in the right click menu.
    public var name: String

    private let taken: Set<AppIdentifier>

    /// Builds the add screen's model, already filled in with a sensible answer.
    ///
    /// Opens ready for a typed bundle name when this mac offered nothing at all, which
    /// only happens on a machine with no apps that open folders.
    ///
    /// - Parameters:
    ///   - found: The apps this mac can open a folder with.
    ///   - taken: The ids already in use, so a new app never clashes.
    public init(found: [OpenerApp], taken: Set<AppIdentifier>) {
        let first = found.first

        choices = found
        self.taken = taken
        isCustom = first == nil
        pickedBundleIdentifier = first?.bundleIdentifier ?? ""
        name = first?.displayName ?? ""
    }

    /// The bundle name the new app will really carry, with nothing blank around it.
    public var chosenBundleIdentifier: String {
        AppCheck.tidied(isCustom ? customBundleIdentifier : pickedBundleIdentifier)
    }

    /// What is wrong with the name, if anything.
    public var nameProblem: AppProblem? { AppCheck.nameProblem(name) }

    /// What is wrong with the bundle name, if anything.
    public var bundleIdentifierProblem: AppProblem? {
        AppCheck.bundleIdentifierProblem(chosenBundleIdentifier)
    }

    /// Whether every part has been filled in and is allowed.
    public var isReady: Bool {
        nameProblem == nil && bundleIdentifierProblem == nil
    }

    /// Picks one of the apps this mac has, filling the name in to match.
    ///
    /// - Parameter bundleIdentifier: The bundle name of the app that was picked.
    public func pick(_ bundleIdentifier: String) {
        guard let choice = choices.first(where: { $0.bundleIdentifier == bundleIdentifier }) else {
            return
        }
        isCustom = false
        pickedBundleIdentifier = choice.bundleIdentifier
        name = choice.displayName
    }

    /// Takes an app somebody picked off the disk.
    ///
    /// An app the dropdown already offers is picked there rather than typed in, so the
    /// same app never turns up twice under two different spellings.
    ///
    /// - Parameter app: What the app calls itself and what the mac finds it by.
    public func use(_ app: FoundApp) {
        guard !choices.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) else {
            pick(app.bundleIdentifier)
            return
        }
        isCustom = true
        customBundleIdentifier = app.bundleIdentifier
        name = app.displayName
    }

    /// Switches to typing a bundle name in rather than picking one.
    ///
    /// The box is emptied on purpose, so nothing is added by accident under an app that
    /// was only ever the starting answer.
    public func useCustom() {
        isCustom = true
        customBundleIdentifier = ""
    }

    /// Builds the app, when there is enough to build one.
    ///
    /// - Returns: The new app, or `nil` while something is still missing.
    public func build() -> OpenerApp? {
        guard isReady, let id = freeIdentifier() else { return nil }
        return OpenerApp(
            id: id,
            displayName: AppCheck.tidied(name),
            bundleIdentifier: chosenBundleIdentifier
        )
    }

    private func freeIdentifier() -> AppIdentifier? {
        AppSuggestion.identifier(
            fromBundleIdentifier: chosenBundleIdentifier,
            avoiding: taken
        )
    }
}
