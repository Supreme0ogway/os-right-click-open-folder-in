/// Every app the right click menu offers to open a folder in.
///
/// One reading of it is the truth for the menu, the editor and the opener alike. An
/// empty list is a normal list: it means the menu shows nothing at all.

/// The apps the user has, in the order they are shown.
public struct AppList: Hashable, Codable, Sendable {

    /// The shape this list was written in.
    public let version: Int

    /// The apps, in menu order, each id appearing once.
    public let apps: [OpenerApp]

    /// A list holding no apps. What an app with nothing set up answers with.
    public static let empty = Self(apps: [])

    /// Builds a list, dropping any repeated id and keeping the first of each.
    ///
    /// - Parameters:
    ///   - version: The shape the list is written in. Defaults to today's.
    ///   - apps: The apps in the order they should appear in the menu.
    public init(version: Int = AppListConstants.schemaVersion, apps: [OpenerApp]) {
        self.version = version
        self.apps = Self.withoutRepeats(apps)
    }

    /// Whether the list offers nothing, in which case the menu shows nothing.
    public var isEmpty: Bool { apps.isEmpty }

    /// Finds the app with this id.
    ///
    /// - Parameter id: The id to look for.
    /// - Returns: The app, or `nil` when the list does not hold it.
    public func app(withId id: AppIdentifier) -> OpenerApp? {
        apps.first { $0.id == id }
    }

    /// A list with this app in it, replacing any app that already had its id.
    ///
    /// A new id goes on the end. A known id keeps its place in the order.
    ///
    /// - Parameter app: The app to put in.
    /// - Returns: A new list. The original is untouched.
    public func adding(_ app: OpenerApp) -> Self {
        guard self.app(withId: app.id) != nil else {
            return Self(version: version, apps: apps + [app])
        }
        return Self(version: version, apps: apps.map { $0.id == app.id ? app : $0 })
    }

    /// A list without the app with this id.
    ///
    /// Removing the last app is allowed and leaves an empty list, which is a state the
    /// whole app is built to handle.
    ///
    /// - Parameter id: The id to take out. An id that is not there changes nothing.
    /// - Returns: A new list. The original is untouched.
    public func removing(_ id: AppIdentifier) -> Self {
        Self(version: version, apps: apps.filter { $0.id != id })
    }

    /// A list with some apps moved to a new place in the order.
    ///
    /// The order is what the right click menu shows, so moving an app here is how
    /// somebody decides where it appears in that menu.
    ///
    /// - Parameters:
    ///   - offsets: Where the apps being moved are now.
    ///   - destination: Where they should land, counted before anything is taken out,
    ///     which is how a list hands over a drag.
    /// - Returns: A new list. The original is untouched.
    public func moving(from offsets: [Int], to destination: Int) -> Self {
        let taken = offsets.sorted().filter { apps.indices.contains($0) }
        guard !taken.isEmpty else { return self }

        let moving = taken.map { apps[$0] }
        let staying = apps.enumerated()
            .filter { !taken.contains($0.offset) }
            .map(\.element)

        let landing = destination - taken.filter { $0 < destination }.count
        return Self(version: version, apps: inserting(moving, into: staying, at: landing))
    }

    private func inserting(
        _ moving: [OpenerApp],
        into staying: [OpenerApp],
        at landing: Int
    ) -> [OpenerApp] {
        let place = min(max(landing, 0), staying.count)
        return Array(staying[..<place]) + moving + Array(staying[place...])
    }

    private static func withoutRepeats(_ apps: [OpenerApp]) -> [OpenerApp] {
        var seen = Set<AppIdentifier>()
        return apps.filter { seen.insert($0.id).inserted }
    }
}
