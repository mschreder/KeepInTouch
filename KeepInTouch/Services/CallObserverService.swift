import Foundation
import CallKit

/// Best-effort "a call just ended" signal. iOS never exposes which number a
/// CXCall was with, so this can only prompt the user to log it manually —
/// it cannot identify who was called. Only fires while the app process is
/// alive (foreground or recently backgrounded), not after a force-quit.
final class CallObserverService: NSObject, CXCallObserverDelegate {
    private let callObserver = CXCallObserver()
    private var connectedCallUUIDs: Set<UUID> = []

    var onCallEnded: (() -> Void)?

    override init() {
        super.init()
        callObserver.setDelegate(self, queue: .main)
    }

    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasConnected && !call.hasEnded {
            connectedCallUUIDs.insert(call.uuid)
        }
        if call.hasEnded && connectedCallUUIDs.remove(call.uuid) != nil {
            onCallEnded?()
        }
    }
}
