//
// Updates the run state of the game and notifies the view.
//

import Foundation
struct RunStateUpdater {
    unowned let runStateDelegate: RunStateDelegate

    init(runStateDelegate: RunStateDelegate) {
        self.runStateDelegate = runStateDelegate
    }

    func update(to runState: RunState, notificationIdentifer: String, error: ExecutionError?) {
        runStateDelegate.runState = runState
        NotificationCenter.default.post(name: Notification.Name(
            rawValue: notificationIdentifer), object: error, userInfo: nil)
    }
}
