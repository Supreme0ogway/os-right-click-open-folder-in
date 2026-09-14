import SwiftUI

/// The "I will type the bundle name myself" option in a chooser.
///
/// Handed in only by the screens that have somewhere to type it. A screen that has not
/// passes nothing, and then the chooser does not offer it at all rather than offering a
/// choice that reveals nothing.
public struct TypedBundleName {

    /// Whether typing is the option chosen now.
    public let isChosen: Bool

    /// What to do when the user says they will type the bundle name.
    public let onChoose: () -> Void

    /// Builds the option.
    ///
    /// - Parameters:
    ///   - isChosen: Whether typing is the option chosen now.
    ///   - onChoose: What to do when the user asks to type one.
    public init(isChosen: Bool, onChoose: @escaping () -> Void) {
        self.isChosen = isChosen
        self.onChoose = onChoose
    }
}

/// The row that says which app this is: its icon, a dropdown of apps, and a way to go
/// and find one the dropdown does not offer.
///
/// The screen that adds an app, the screen that changes one and the setting for which
/// app folders open in all use this, so none of them can offer different things or
/// behave differently when something is picked.
///
/// Holds no words of its own and remembers nothing. Whoever uses it says what is
/// chosen now and is told when that changes.
public struct AppChooser: View {

    private let choices: [OpenerApp]
    private let bundleIdentifier: String
    private let typing: TypedBundleName?
    private let onChoose: (FoundApp) -> Void

    /// Builds the row.
    ///
    /// - Parameters:
    ///   - choices: The apps to offer in the dropdown.
    ///   - bundleIdentifier: What the mac finds the app chosen now by. Empty for none.
    ///   - typing: The type-it-in option, or `nil` on a screen with nowhere to type.
    ///   - onChoose: Called with an app picked from the dropdown or found on the disk.
    public init(
        choices: [OpenerApp],
        bundleIdentifier: String,
        typing: TypedBundleName?,
        onChoose: @escaping (FoundApp) -> Void
    ) {
        self.choices = choices
        self.bundleIdentifier = bundleIdentifier
        self.typing = typing
        self.onChoose = onChoose
    }

    public var body: some View {
        HStack(spacing: ChooserLayout.iconGap) {
            AppIcon(bundleIdentifier: bundleIdentifier, side: IconLayout.pickerSize)

            Picker(UIText.addFound, selection: choiceBinding) {
                if bundleIdentifier.isEmpty, typing == nil {
                    Text(UIText.choosePrompt).tag(ChooserLayout.nothingTag)
                }

                ForEach(choices) { choice in
                    Text(choice.displayName).tag(choice.bundleIdentifier)
                }

                if typing != nil {
                    Text(UIText.addCustom).tag(ChooserLayout.customTag)
                }
            }
            .labelsHidden()

            Button(UIText.browse, action: browse)
        }
    }

    private var choiceBinding: Binding<String> {
        Binding(
            get: { chosenTag },
            set: { picked in take(picked) }
        )
    }

    private var chosenTag: String {
        guard typing?.isChosen != true else { return ChooserLayout.customTag }
        return bundleIdentifier.isEmpty ? ChooserLayout.nothingTag : bundleIdentifier
    }

    private func take(_ picked: String) {
        guard let choice = choices.first(where: { $0.bundleIdentifier == picked }) else {
            typing?.onChoose()
            return
        }
        onChoose(
            FoundApp(
                displayName: choice.displayName,
                bundleIdentifier: choice.bundleIdentifier
            )
        )
    }

    private func browse() {
        guard let found = ApplicationPanel.ask() else { return }
        onChoose(found)
    }
}

/// Fixed sizes and names for the row that picks an app.
public enum ChooserLayout {

    /// The value the dropdown uses for the typed entry. Never a real bundle name.
    public static let customTag = "  other  "

    /// The value the dropdown uses while nothing has been picked at all.
    public static let nothingTag = "  nothing  "

    /// The space between the icon and the dropdown beside it.
    static let iconGap: CGFloat = 12
}
