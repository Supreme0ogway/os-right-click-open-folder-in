import AppKit
import SwiftUI

/// The icon the mac itself uses for an app.
///
/// Asking the system means an app looks like itself, at whatever size the screen needs,
/// with no pictures of our own to keep up to date. An app this mac does not have falls
/// back to a dashed outline, which is what the Finder shows for the same thing.
public struct AppIcon: View {

    private let bundleIdentifier: String
    private let side: CGFloat

    /// Builds the icon.
    ///
    /// - Parameters:
    ///   - bundleIdentifier: What the mac finds the app by.
    ///   - side: How big to draw it, in points. Defaults to the size a form shows.
    public init(bundleIdentifier: String, side: CGFloat = IconLayout.size) {
        self.bundleIdentifier = bundleIdentifier
        self.side = side
    }

    public var body: some View {
        picture
            .resizable()
            .interpolation(.high)
            .frame(width: side, height: side)
            .accessibilityHidden(true)
    }

    private var picture: Image {
        guard let url = InstalledApps.applicationURL(for: bundleIdentifier) else {
            return Image(systemName: IconLayout.missingIconName)
        }
        return Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
    }
}

/// Fixed sizes and symbols for an app's icon.
public enum IconLayout {

    /// How big the icon is shown on a form.
    public static let size: CGFloat = 52

    /// How big the icon is shown on a row in the list.
    public static let rowSize: CGFloat = 18

    /// How big the icon is shown beside the dropdown on the add screen.
    public static let pickerSize: CGFloat = 34

    /// The symbol shown for an app this mac does not have.
    public static let missingIconName = "questionmark.app.dashed"
}
