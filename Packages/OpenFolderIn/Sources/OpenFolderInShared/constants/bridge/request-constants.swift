/// The words the Finder extension and this app use to ask for a folder to be opened.
public enum RequestConstants {

    /// The only thing the extension ever asks this app to do.
    public static let openAction = "open"

    /// The part of the address naming which app to open the folder in.
    public static let appField = "app"

    /// The part of the address naming the folder to open.
    public static let folderField = "folder"
}

/// Fixed facts about the note the extension leaves after each click.
public enum TrailConstants {

    /// The file the extension writes what it last did into.
    public static let fileName = "last-request.json"
}
