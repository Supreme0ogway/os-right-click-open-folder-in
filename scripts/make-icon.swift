import AppKit

/// Draws the app's icon and writes every size a mac asks for.
///
/// Run through `scripts/make-icon.sh`, which turns what this writes into the icon file
/// the app carries. Kept as a drawing rather than a picture so the icon can be changed
/// by editing numbers, and so nothing binary has to be read to know what it looks like.

/// Fixed facts about how the icon is drawn.
enum IconDesign {

    /// The side of the square the icon is drawn on, before it is scaled down.
    static let canvas: CGFloat = 1024

    /// How much clear space a mac icon leaves around itself.
    static let margin: CGFloat = 100

    /// How round the corners of the tile are.
    static let cornerRadius: CGFloat = 200

    /// The teal at the top of the tile.
    static let tileTop = NSColor(srgbRed: 0.20, green: 0.80, blue: 0.76, alpha: 1)

    /// The deeper teal at the bottom of the tile.
    static let tileBottom = NSColor(srgbRed: 0.04, green: 0.45, blue: 0.48, alpha: 1)

    /// The folder drawn on the tile.
    static let folderColor = NSColor.white

    /// How wide the folder is, as a share of the tile.
    static let folderWidthShare: CGFloat = 0.66

    /// How tall the folder's body is, as a share of the tile.
    static let folderHeightShare: CGFloat = 0.48

    /// How round the folder's corners are, as a share of the folder width.
    static let folderCornerShare: CGFloat = 0.07

    /// How wide the tab on top of the folder is, as a share of the folder width.
    static let tabWidthShare: CGFloat = 0.42

    /// How tall the tab on top of the folder is, as a share of the folder height.
    static let tabHeightShare: CGFloat = 0.17

    /// How long the arrow is, as a share of the folder width.
    static let arrowLengthShare: CGFloat = 0.44

    /// How thick the arrow's shaft is, as a share of the folder width.
    static let arrowThicknessShare: CGFloat = 0.11

    /// How wide the arrow's head is, as a share of the folder width.
    static let arrowHeadShare: CGFloat = 0.26

    /// The sizes a mac icon file holds, each written at one and two times.
    static let sizes: [Int] = [16, 32, 128, 256, 512]
}

/// Draws the icon once, at the full canvas size.
func drawIcon(into context: CGContext) {
    let canvas = IconDesign.canvas
    let inset = IconDesign.margin
    let tile = CGRect(x: inset, y: inset, width: canvas - inset * 2, height: canvas - inset * 2)

    drawTile(tile, into: context)

    let folderWidth = tile.width * IconDesign.folderWidthShare
    let folderHeight = tile.height * IconDesign.folderHeightShare
    let folder = CGRect(
        x: tile.midX - folderWidth / 2,
        y: tile.midY - folderHeight / 2,
        width: folderWidth,
        height: folderHeight
    )

    drawFolder(folder, into: context)
    drawArrow(on: folder, into: context)
}

private func drawTile(_ tile: CGRect, into context: CGContext) {
    let path = CGPath(
        roundedRect: tile,
        cornerWidth: IconDesign.cornerRadius,
        cornerHeight: IconDesign.cornerRadius,
        transform: nil
    )
    context.saveGState()
    context.addPath(path)
    context.clip()

    let colors = [IconDesign.tileBottom.cgColor, IconDesign.tileTop.cgColor] as CFArray
    guard let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: colors,
        locations: [0, 1]
    ) else {
        context.restoreGState()
        return
    }
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: tile.midX, y: tile.minY),
        end: CGPoint(x: tile.midX, y: tile.maxY),
        options: []
    )
    context.restoreGState()
}

private func drawFolder(_ folder: CGRect, into context: CGContext) {
    let corner = folder.width * IconDesign.folderCornerShare
    let tabWidth = folder.width * IconDesign.tabWidthShare
    let tabHeight = folder.height * IconDesign.tabHeightShare
    let tab = CGRect(x: folder.minX, y: folder.maxY - corner, width: tabWidth, height: tabHeight)

    context.setFillColor(IconDesign.folderColor.cgColor)
    context.addPath(
        CGPath(roundedRect: tab, cornerWidth: corner, cornerHeight: corner, transform: nil)
    )
    context.addPath(
        CGPath(roundedRect: folder, cornerWidth: corner, cornerHeight: corner, transform: nil)
    )
    context.fillPath()
}

private func drawArrow(on folder: CGRect, into context: CGContext) {
    let length = folder.width * IconDesign.arrowLengthShare
    let thickness = folder.width * IconDesign.arrowThicknessShare
    let head = folder.width * IconDesign.arrowHeadShare
    let left = folder.midX - length / 2
    let middle = folder.midY

    let shaft = CGRect(
        x: left,
        y: middle - thickness / 2,
        width: length - head / 2,
        height: thickness
    )
    let point = CGMutablePath()
    point.move(to: CGPoint(x: left + length, y: middle))
    point.addLine(to: CGPoint(x: left + length - head, y: middle + head / 2))
    point.addLine(to: CGPoint(x: left + length - head, y: middle - head / 2))
    point.closeSubpath()

    context.setFillColor(IconDesign.tileBottom.cgColor)
    context.addPath(
        CGPath(
            roundedRect: shaft,
            cornerWidth: thickness / 2,
            cornerHeight: thickness / 2,
            transform: nil
        )
    )
    context.addPath(point)
    context.fillPath()
}

/// Writes one square picture of the icon.
func writePNG(side: Int, to url: URL) throws {
    guard let context = CGContext(
        data: nil,
        width: side,
        height: side,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { throw IconError.cannotDraw }

    let scale = CGFloat(side) / IconDesign.canvas
    context.scaleBy(x: scale, y: scale)
    context.setAllowsAntialiasing(true)
    drawIcon(into: context)

    guard let image = context.makeImage() else { throw IconError.cannotDraw }
    let rep = NSBitmapImageRep(cgImage: image)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw IconError.cannotDraw
    }
    try data.write(to: url)
}

/// Why the icon could not be made.
enum IconError: Error {
    case cannotDraw
    case noDestination
}

let arguments = CommandLine.arguments
guard arguments.count > 1 else { throw IconError.noDestination }
let iconset = URL(filePath: arguments[1])
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

for size in IconDesign.sizes {
    try writePNG(side: size, to: iconset.appending(path: "icon_\(size)x\(size).png"))
    try writePNG(side: size * 2, to: iconset.appending(path: "icon_\(size)x\(size)@2x.png"))
}
print("drew \(IconDesign.sizes.count * 2) sizes into \(iconset.path)")
