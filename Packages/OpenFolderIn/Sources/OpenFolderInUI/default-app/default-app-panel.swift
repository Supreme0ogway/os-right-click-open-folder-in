import SwiftUI

/// The part of settings that chooses which app a folder opens in by default.
///
/// The default comes first in the right click menu and is marked there, the way the
/// Finder's own Open With marks a file's default. Picking none is allowed and leaves
/// the menu offering everything with nothing marked.
///
/// The top dropdown offers the apps already in the list. *Other…* reveals a second one
/// holding every app this mac can open a folder with, so a default can be picked
/// without going to add the app first.
///
/// Layout only. Which apps are offered and what taking one does are the model's job.
struct DefaultAppPanel: View {

    let model: DefaultAppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: FieldLayout.rowGap) {
            chooser

            if model.isOther {
                other
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FieldLayout.formPadding)
    }

    private var chooser: some View {
        VStack(alignment: .leading, spacing: FieldLayout.lineGap) {
            FieldLabel(UIText.defaultAppLabel)

            Picker(UIText.defaultAppLabel, selection: pickedBinding) {
                Text(UIText.defaultAppNone).tag(DefaultAppLayout.noneTag)
                ForEach(model.choices) { choice in
                    Text(choice.displayName).tag(choice.id.text)
                }
                Text(UIText.addCustom).tag(DefaultAppLayout.otherTag)
            }
            .labelsHidden()
            .fixedSize()

            Text(UIText.defaultAppNote)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var other: some View {
        VStack(alignment: .leading, spacing: FieldLayout.lineGap) {
            FieldLabel(UIText.defaultAppOtherLabel)

            AppChooser(
                choices: model.found,
                bundleIdentifier: model.otherBundleIdentifier,
                typing: nil,
                onChoose: model.take
            )

            Text(UIText.defaultAppOtherNote)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var pickedBinding: Binding<String> {
        Binding(
            get: { pickedTag },
            set: { picked in pick(picked) }
        )
    }

    private var pickedTag: String {
        guard !model.isOther else { return DefaultAppLayout.otherTag }
        return model.defaultAppId?.text ?? DefaultAppLayout.noneTag
    }

    private func pick(_ picked: String) {
        guard picked != DefaultAppLayout.otherTag else {
            model.useOther()
            return
        }
        guard let id = try? AppIdentifier(picked) else {
            model.clear()
            return
        }
        model.choose(id)
    }
}

/// Fixed names for the panel that chooses the default app.
enum DefaultAppLayout {

    /// The value the dropdown uses for picking nothing. Never a real id.
    static let noneTag = "  none  "

    /// The value the dropdown uses for an app not in the list. Never a real id.
    static let otherTag = "  other  "
}
