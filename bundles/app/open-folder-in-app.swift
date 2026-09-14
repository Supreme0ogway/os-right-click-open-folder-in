import FinderSync
import SwiftUI

/// Where the app starts.
///
/// There is no window and no dock icon. The app is an icon in the menu bar that keeps
/// the list of apps, answers the Finder extension, and otherwise stays out of the way.
/// Because there is no dock icon there is no other way to close it, so the menu always
/// offers a way out.
@main
struct OpenFolderInApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenu(services: delegate.services, editor: delegate.editor)
        } label: {
            Image(systemName: MenuBarConstants.iconName)
                .renderingMode(.template)
                .symbolRenderingMode(.monochrome)
                .font(.system(size: MenuBarConstants.pointSize, weight: .regular))
                .accessibilityLabel(AppText.menuTitle)
        }
        .menuBarExtraStyle(.menu)
    }
}

/// Fixed facts about the menu bar item.
enum MenuBarConstants {

    /// The system icon shown in the menu bar.
    ///
    /// A system symbol rather than a picture of our own, so the menu bar draws it at
    /// whatever sharpness the screen needs and follows light and dark of its own accord.
    ///
    /// - Note: A busy symbol is what looks soft up there. A badge or a second shape has
    ///   to survive being drawn about fourteen points tall, and one that does not comes
    ///   out as a smudge. This one is two plain shapes.
    static let iconName = "arrow.up.forward.app"

    /// How tall the symbol is drawn, in points.
    ///
    /// Said out loud so the symbol is drawn at this size rather than drawn at some
    /// other size and scaled to fit, which is the other way an icon goes soft.
    static let pointSize: CGFloat = 15
}
