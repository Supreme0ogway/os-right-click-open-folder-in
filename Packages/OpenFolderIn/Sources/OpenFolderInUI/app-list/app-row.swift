import SwiftUI

/// One app in the list, with its icon and whether it is the default.
///
/// The colors are worked out here and written down as fixed ones, rather than left as
/// the system's own light-or-dark colors. A row lifted out by a drag is drawn again
/// somewhere that does not inherit the window's light or dark, and anything that is
/// still asking the system at that point comes back with the wrong answer, which is
/// how a dragged row came out as black words on a dark list.
struct AppRow: View {

    let app: OpenerApp
    let isDefault: Bool
    let appearance: ColorScheme

    var body: some View {
        HStack(spacing: AppRowLook.iconGap) {
            AppIcon(bundleIdentifier: app.bundleIdentifier, side: IconLayout.rowSize)

            Text(app.displayName)
                .foregroundStyle(words)

            Spacer()

            if isDefault {
                Image(systemName: AppRowLook.defaultIconName)
                    .font(.caption)
                    .foregroundStyle(Brand.accent)
                    .help(UIText.isDefault)
            }
        }
    }

    private var words: Color {
        appearance == .dark ? .white : .black
    }
}

/// How a row in the list is spaced and marked.
enum AppRowLook {

    /// The space between the icon and the name beside it.
    static let iconGap: CGFloat = 8

    /// The symbol shown on the app a folder opens in by default.
    static let defaultIconName = "star.fill"
}
