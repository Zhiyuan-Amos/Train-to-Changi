//
// Updates the run state of the game and notifies the view.
//

import Foundation
struct RunStateUpdater {
    let runStateProtocol: RunStateProtocol

    init(runStateProtocol: RunStateProtocol) {
        self.runStateProtocol = runStateProtocol
    }

    func update(to runState: RunState, notificationIdentifer: String, error: ExecutionError?) {
        runStateProtocol.updateRunState(to: runState)
        NotificationCenter.default.post(name: Notification.Name(
            rawValue: notificationIdentifer), object: error, userInfo: nil)
    }
}
