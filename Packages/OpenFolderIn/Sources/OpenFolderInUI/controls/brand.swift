import SwiftUI

/// The app's own colors.
///
/// The same teal as the icon, so a window that has no dock icon behind it is still
/// plainly this app and not a system panel. Every control reads its accent from here,
/// so the accent is changed in one place.
public enum Brand {

    /// The teal at the top of the icon's tile.
    public static let light = Color(.sRGB, red: 0.20, green: 0.80, blue: 0.76)

    /// The deeper teal at the bottom of the icon's tile.
    public static let deep = Color(.sRGB, red: 0.04, green: 0.45, blue: 0.48)

    /// The color a control uses to say it is the one being pointed at.
    public static let accent = deep

    /// The color across the top of a window.
    ///
    /// Full color at the left, where the title sits, fading to nothing a little past
    /// it. Nothing else in the window is colored: the list and the panel keep the
    /// system's own background.
    public static let band = LinearGradient(
        stops: [
            .init(color: deep, location: 0),
            .init(color: light, location: BrandBand.fadeStart),
            .init(color: light.opacity(0), location: BrandBand.fadeEnd),
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

/// Where the color across the top of a window fades out.
enum BrandBand {

    /// How far along the band the color starts to go, as a share of the width.
    static let fadeStart = 0.18

    /// How far along the band the color is gone, as a share of the width.
    static let fadeEnd = 0.38
}
