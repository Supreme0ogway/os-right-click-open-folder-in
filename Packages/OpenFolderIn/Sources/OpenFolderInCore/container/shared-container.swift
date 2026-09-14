import Foundation

/// Where this app and the Finder extension meet.
///
/// The extension runs in a sandbox and cannot read this app's own folders, so the two
/// share a container the system hands to both. This app writes the list of apps, the
/// default and the scope there and the extension only ever reads them.
///
/// - Note: A container path that comes back is not proof of access. The system works
///   the path out without checking it, and an extension that is not allowed in gets no
///   prompt and no error, only an empty read. Treat a failed read as "nothing saved".

/// Finds the files this app and the extension share.
public enum SharedContainer {

    /// The shared folder, or `nil` when the system will not give one out.
    ///
    /// Comes back `nil` when the group name is wrong or the bundle is signed by the
    /// wrong team, which are both build problems rather than things a user can fix.
    public static var folderURL: URL? {
        guard let team = SigningTeam.identifier else { return nil }
        return FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: BundleConstants.appGroupIdentifier(team: team)
        )
    }

    /// Where the list of apps is kept.
    public static var appListFileURL: URL? {
        folderURL?.appending(path: AppListConstants.fileName)
    }

    /// Where the scope setting is kept.
    public static var scopeFileURL: URL? {
        folderURL?.appending(path: ScopeConstants.fileName)
    }

    /// Where the choices the app remembers are kept.
    public static var preferencesFileURL: URL? {
        folderURL?.appending(path: PreferencesConstants.fileName)
    }

    /// Where the extension writes what it last did.
    public static var trailFileURL: URL? {
        folderURL?.appending(path: TrailConstants.fileName)
    }

    /// Whether the shared folder can really be written to, not just named.
    ///
    /// Writes a small file and removes it again, because naming the folder always
    /// works and says nothing about whether the system will let this bundle in.
    ///
    /// - Returns: `true` when a write went through.
    public static func canBeWrittenTo() -> Bool {
        guard let folder = folderURL else { return false }
        let probe = folder.appending(path: ContainerConstants.probeFileName)
        guard (try? Data().write(to: probe)) != nil else { return false }
        try? FileManager.default.removeItem(at: probe)
        return true
    }
}
