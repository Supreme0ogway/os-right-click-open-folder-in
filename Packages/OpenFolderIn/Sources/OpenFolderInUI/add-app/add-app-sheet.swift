import SwiftUI

/// The screen for adding an app.
///
/// Deliberately short: which app, and what the menu should call it. Anything else is
/// changed afterwards on the screen made for it, so nothing here has to be decided
/// twice.
///
/// Layout only. What is offered and what counts as filled in are the model's job.
struct AddAppSheet: View {

    @State private var model: AddAppViewModel

    private let onAdd: (OpenerApp) -> Void
    private let onCancel: () -> Void

    init(
        model: AddAppViewModel,
        onAdd: @escaping (OpenerApp) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self._model = State(initialValue: model)
        self.onAdd = onAdd
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AddAppLayout.rowGap) {
            AppChooser(
                choices: model.choices,
                bundleIdentifier: model.chosenBundleIdentifier,
                typing: TypedBundleName(isChosen: model.isCustom, onChoose: model.useCustom),
                onChoose: model.use
            )

            if model.isCustom {
                LabelledField(
                    label: UIText.bundleIdentifier,
                    placeholder: UIText.bundleIdentifierPlaceholder,
                    hint: UIText.bundleIdentifierHint,
                    problem: UIText.saying(model.bundleIdentifierProblem),
                    text: $model.customBundleIdentifier
                )
            }

            LabelledField(
                label: UIText.name,
                problem: UIText.saying(model.nameProblem),
                text: $model.name
            )

            buttons
        }
        .padding(AddAppLayout.padding)
        .frame(width: AddAppLayout.width)
    }

    private var buttons: some View {
        HStack {
            Button(UIText.addCancel, action: onCancel)
                .keyboardShortcut(.cancelAction)
            Spacer()
            Button(UIText.addConfirm, action: add)
                .keyboardShortcut(.defaultAction)
                .disabled(!model.isReady)
        }
        .padding(.top, AddAppLayout.buttonsTopPadding)
    }

    private func add() {
        guard let app = model.build() else { return }
        onAdd(app)
    }
}

/// Fixed sizes for the add screen.
enum AddAppLayout {

    /// How wide the screen is. Wide enough for the dropdown and the browse button.
    static let width: CGFloat = 440

    /// The space around everything on the screen.
    static let padding: CGFloat = 24

    /// The space between one row and the next.
    static let rowGap: CGFloat = 18

    /// The extra space above the buttons at the bottom.
    static let buttonsTopPadding: CGFloat = 6
}
