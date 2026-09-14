import Testing

@testable import OpenFolderInCore

@Suite("Built in apps")
struct BuiltInAppsTests {

    @Test("The shipped list can be read")
    func shippedListLoads() {
        #expect(!BuiltInApps.load().isEmpty)
    }

    @Test("Every shipped app belongs to the namespace the app itself owns")
    func shippedAppsAreNamespaced() {
        let namespaces = BuiltInApps.load().apps.map(\.id.namespace)

        #expect(namespaces.allSatisfy { $0 == IdentifierConstants.builtInNamespace })
    }

    @Test("Every shipped app names something for the mac to find it by")
    func shippedAppsNameABundle() {
        let identifiers = BuiltInApps.load().apps.map(\.bundleIdentifier)

        #expect(identifiers.allSatisfy { AppCheck.bundleIdentifierProblem($0) == nil })
    }

    @Test("Every shipped app has something to show in the menu")
    func shippedAppsHaveAName() {
        #expect(BuiltInApps.load().apps.allSatisfy { !$0.displayName.isEmpty })
    }

    @Test("A first run offers only the shipped apps that are really installed")
    func startingListKeepsOnlyInstalled() {
        let shipped = BuiltInApps.load()
        let wanted = shipped.apps.first?.bundleIdentifier ?? ""

        let starting = BuiltInApps.startingList(from: shipped) { $0 == wanted }

        #expect(starting.apps.map(\.bundleIdentifier) == [wanted])
    }

    @Test("A first run with none of them installed offers nothing, which is allowed")
    func startingListCanBeEmpty() {
        #expect(BuiltInApps.startingList(from: BuiltInApps.load()) { _ in false }.isEmpty)
    }

    @Test("A first run keeps the shipped order, which is the order the menu shows")
    func startingListKeepsOrder() {
        let shipped = BuiltInApps.load()

        let starting = BuiltInApps.startingList(from: shipped) { _ in true }

        #expect(starting.apps.map(\.id.text) == shipped.apps.map(\.id.text))
    }
}
