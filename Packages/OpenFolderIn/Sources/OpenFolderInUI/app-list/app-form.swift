import SwiftUI

/// The rows for editing one app.
///
/// The same dropdown the add screen offers, so an entry can be pointed at a different
/// app without being removed and added again, and the bundle name can still be typed
/// for anything the dropdown does not know.
///
/// Layout only. What counts as a usable name or bundle name is decided in the checks the
/// whole app shares, and the one true copy of the app is kept by the model.
struct AppForm: View {

    let app: OpenerApp
    let model: AppListViewModel
    let defaultApp: DefaultAppViewModel

    @State private var displayName = ""
    @State private var bundleIdentifier = ""
    @State private var isCustom = false

    private let choices = InstalledApps.thatCanOpenFolders()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FieldLayout.rowGap) {
                chooser

                LabelledField(
                    label: UIText.name,
                    hint: UIText.nameHint,
                    problem: UIText.saying(AppCheck.nameProblem(displayName)),
                    text: $displayName
                )

                LabelledField(
                    label: UIText.bundleIdentifier,
                    placeholder: UIText.bundleIdentifierPlaceholder,
                    hint: bundleIdentifierHint,
                    problem: UIText.saying(AppCheck.bundleIdentifierProblem(bundleIdentifier)),
                    text: $bundleIdentifier
                )

                defaultButton
            }
            .padding(FieldLayout.formPadding)
        }
        .overlay(alignment: .bottomTrailing) { removeBubble }
        .onAppear(perform: fillFromApp)
        .onChange(of: displayName) { _, _ in save() }
        .onChange(of: bundleIdentifier) { _, _ in save() }
    }

    private var chooser: some View {
        AppChooser(
            choices: choices,
            bundleIdentifier: bundleIdentifier,
            typing: TypedBundleName(isChosen: isCustom, onChoose: typeItIn),
            onChoose: take
        )
    }

    private var bundleIdentifierHint: String {
        isInstalled ? UIText.bundleIdentifierHint : UIText.notInstalled
    }

    private var isInstalled: Bool {
        InstalledApps.isInstalled(AppCheck.tidied(bundleIdentifier))
    }

    @ViewBuilder
    private var defaultButton: some View {
        if defaultApp.isDefault(app.id) {
            Button(UIText.removeDefault, systemImage: AppFormLayout.isDefaultIconName) {
                defaultApp.clear()
            }
            .tint(Brand.accent)
        }

        if !defaultApp.isDefault(app.id) {
            Button(UIText.makeDefault, systemImage: AppFormLayout.makeDefaultIconName) {
                defaultApp.choose(app.id)
            }
        }
    }

    private var removeBubble: some View {
        Button {
            model.askToRemove(app.id)
        } label: {
            Image(systemName: AppFormLayout.removeIconName)
                .font(.system(size: AppFormLayout.bubbleIconSize, weight: .semibold))
                .foregroundStyle(.red)
                .frame(width: AppFormLayout.bubbleSize, height: AppFormLayout.bubbleSize)
                .background(.regularMaterial, in: Circle())
                .overlay(Circle().strokeBorder(.separator))
                .shadow(radius: AppFormLayout.bubbleShadow, y: AppFormLayout.bubbleShadowDrop)
        }
        .buttonStyle(.plain)
        .help(UIText.remove)
        .padding(AppFormLayout.bubblePadding)
    }

    private func take(_ found: FoundApp) {
        isCustom = false
        bundleIdentifier = found.bundleIdentifier
        displayName = found.displayName
    }

    private func typeItIn() {
        isCustom = true
        bundleIdentifier = ""
    }

    private func fillFromApp() {
        displayName = app.displayName
        bundleIdentifier = app.bundleIdentifier
        isCustom = !choices.contains { $0.bundleIdentifier == app.bundleIdentifier }
    }

    private func save() {
        let hasProblem = AppCheck.nameProblem(displayName) != nil
            || AppCheck.bundleIdentifierProblem(bundleIdentifier) != nil
        guard !hasProblem else { return }

        model.updateApp(
            OpenerApp(
                id: app.id,
                displayName: AppCheck.tidied(displayName),
                bundleIdentifier: AppCheck.tidied(bundleIdentifier)
            )
        )
    }
}

/// Fixed sizes and symbols for the form that edits one app.
enum AppFormLayout {

    /// The symbol on the button that removes an app.
    static let removeIconName = "trash"

    /// The symbol on the button that makes an app the default.
    static let makeDefaultIconName = "star"

    /// The symbol on the button that stops an app being the default.
    static let isDefaultIconName = "star.slash"

    /// How wide the floating remove button is.
    static let bubbleSize: CGFloat = 44

    /// How big the trash on the floating remove button is.
    static let bubbleIconSize: CGFloat = 17

    /// How far the floating remove button sits from the corner.
    static let bubblePadding: CGFloat = 18

    /// How soft the floating remove button's shadow is.
    static let bubbleShadow: CGFloat = 6

    /// How far the floating remove button's shadow falls.
    static let bubbleShadowDrop: CGFloat = 2
}
