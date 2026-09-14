import Foundation
import Observation

/// Writing the apps out to a file, and reading them back in.
///
/// A file that cannot be read leaves the list exactly as it was and says so. Nothing is
/// half brought in: either the whole file was a list of apps or none of it was.
@MainActor
@Observable
public final class TransferViewModel {

    /// The store the apps are written out of and read back into.
    public let store: RecordStore<AppList>

    /// What went wrong the last time, if anything did.
    public private(set) var problem: String?

    /// Builds the model.
    ///
    /// - Parameter store: The one copy of the apps.
    public init(store: RecordStore<AppList>) {
        self.store = store
    }

    /// What a written out file should be called.
    public var suggestedFileName: String { AppListTransfer.suggestedFileName }

    /// Writes every app out to a file.
    ///
    /// - Parameter destination: Where to write it.
    public func export(to destination: URL) {
        do {
            try AppListTransfer.data(for: store.value).write(to: destination)
            problem = nil
        } catch {
            problem = error.localizedDescription
        }
    }

    /// Reads apps in from a file and adds them to the list.
    ///
    /// - Parameter source: The file to read.
    public func importFrom(_ source: URL) {
        guard let data = try? Data(contentsOf: source),
              let incoming = try? AppListTransfer.list(from: data)
        else {
            problem = UIText.fileIsDamaged
            return
        }

        do {
            try store.save(AppListTransfer.joining(incoming, into: store.value))
            problem = nil
        } catch {
            problem = error.localizedDescription
        }
    }

    /// Takes the last message away.
    public func clearProblem() {
        problem = nil
    }
}
