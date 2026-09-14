import Foundation
import Testing

@testable import OpenFolderInCore

@Suite("Watch list")
struct WatchListTests {

    @Test("Watching everywhere watches the top of the disk")
    func everywhereWatchesTheTop() {
        let folders = WatchList.folderURLs(for: .everywhere, volumeRoots: [])

        #expect(folders == [URL(filePath: "/")])
    }

    @Test("Watching everywhere names each mounted drive, which the top does not cover")
    func everywhereNamesEachDrive() {
        let drive = URL(filePath: "/Volumes/Backup")

        let folders = WatchList.folderURLs(for: .everywhere, volumeRoots: [drive])

        #expect(folders.contains(drive))
        #expect(folders.contains(URL(filePath: "/")))
    }

    @Test("Watching picked folders watches exactly those")
    func pickedFoldersAreWatched() {
        let scope = Scope(places: .folders(["/Users/someone/Code"]))

        let folders = WatchList.folderURLs(for: scope, volumeRoots: [])

        #expect(folders == [URL(filePath: "/Users/someone/Code")])
    }

    @Test("Watching picked folders ignores the mounted drives")
    func pickedFoldersIgnoreDrives() {
        let scope = Scope(places: .folders(["/Users/someone/Code"]))

        let folders = WatchList.folderURLs(for: scope, volumeRoots: [URL(filePath: "/Volumes/X")])

        #expect(folders.count == 1)
    }

    @Test("Picking folders and removing them all watches nothing, so no menu anywhere")
    func noFoldersWatchesNothing() {
        #expect(WatchList.folderURLs(for: Scope(places: .folders([])), volumeRoots: []).isEmpty)
    }
}
