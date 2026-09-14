import Foundation

/// One ask from the Finder extension to this app: open this folder in that app.
///
/// The extension runs in a sandbox and is not allowed to launch anything, so it asks
/// this app instead. The ask travels as an address, which also starts this app when it
/// is not already running.
///
/// Reading one is deliberately strict. Anything on the machine can send an address, so
/// a request that is not exactly right is refused rather than guessed at.

/// A request to open one folder in one app.
public struct LaunchRequest: Hashable, Sendable {

    /// The app to open the folder in.
    public let appId: AppIdentifier

    /// The folder to open, as an absolute path.
    public let folderPath: String

    /// Builds a request.
    ///
    /// - Parameters:
    ///   - appId: The app to open the folder in.
    ///   - folderPath: The folder to open, as an absolute path.
    public init(appId: AppIdentifier, folderPath: String) {
        self.appId = appId
        self.folderPath = folderPath
    }

    /// Reads a request out of an address, refusing anything that is not one.
    ///
    /// - Parameter url: The address this app was opened with.
    /// - Returns: The request, or `nil` when the address is not a well formed one.
    public init?(url: URL) {
        guard url.scheme == BundleConstants.urlScheme else { return nil }
        guard url.host() == RequestConstants.openAction else { return nil }

        let fields = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        guard let appText = fields.first(where: { $0.name == RequestConstants.appField })?.value,
              let folder = fields.first(where: { $0.name == RequestConstants.folderField })?.value,
              let appId = try? AppIdentifier(appText),
              folder.hasPrefix(ScopeConstants.rootPath)
        else { return nil }

        self.appId = appId
        self.folderPath = folder
    }

    /// The request written as an address this app can be opened with.
    public var url: URL {
        var components = URLComponents()
        components.scheme = BundleConstants.urlScheme
        components.host = RequestConstants.openAction
        components.queryItems = [
            URLQueryItem(name: RequestConstants.appField, value: appId.text),
            URLQueryItem(name: RequestConstants.folderField, value: folderPath),
        ]
        return components.url ?? URL(filePath: ScopeConstants.rootPath)
    }
}
