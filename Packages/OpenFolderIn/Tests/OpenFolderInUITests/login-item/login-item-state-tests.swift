import ServiceManagement
import Testing

@testable import OpenFolderInUI

@Suite("Login item state")
struct LoginItemStateTests {

    @Test("A setting that is on shows as on")
    func enabledIsOn() {
        #expect(LoginItemState.from(.enabled) == .on)
    }

    @Test("A setting nobody has asked for shows as off")
    func notRegisteredIsOff() {
        #expect(LoginItemState.from(.notRegistered) == .off)
    }

    @Test("A setting the system cannot find shows as off")
    func notFoundIsOff() {
        #expect(LoginItemState.from(.notFound) == .off)
    }

    @Test("A setting waiting to be allowed shows as waiting")
    func requiresApprovalIsWaiting() {
        #expect(LoginItemState.from(.requiresApproval) == .waitingForApproval)
    }

    @Test("Waiting still counts as ticked, because the user asked for it")
    func waitingIsTicked() {
        #expect(LoginItemState.waitingForApproval.isChecked)
    }

    @Test("Off is not ticked")
    func offIsNotTicked() {
        #expect(!LoginItemState.off.isChecked)
    }

    @Test("Clicking something off asks for it")
    func clickingOffAsksForIt() {
        #expect(LoginItemState.off.nextAction == .add)
    }

    @Test("Clicking something on takes it off")
    func clickingOnTakesItOff() {
        #expect(LoginItemState.on.nextAction == .remove)
    }

    @Test("Clicking something waiting takes it off, rather than asking twice")
    func clickingWaitingTakesItOff() {
        #expect(LoginItemState.waitingForApproval.nextAction == .remove)
    }

    @Test("Only the waiting state tells the user to go to System Settings")
    func onlyWaitingNeedsApproval() {
        #expect(LoginItemState.waitingForApproval.needsApproval)
        #expect(!LoginItemState.on.needsApproval)
        #expect(!LoginItemState.off.needsApproval)
    }
}
