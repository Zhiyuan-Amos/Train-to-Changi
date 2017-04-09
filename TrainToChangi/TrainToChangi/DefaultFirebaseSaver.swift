//
//  DefaultFirebaseSaver.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 9/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

// Automatically saves user's entered commands for each level under the "default"
// saved level name, to allow user's entered commands to be persisted
// even without manual saving.
class DefaultFirebaseSaver {

    init() {
        initNotification()
    }

    private func initNotification() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(commandDataListUpdate(notification:)),
            name: Constants.NotificationNames.commandDataListUpdate, object: nil)
    }

    @objc private func commandDataListUpdate(notification: Notification) {
        guard let levelIndex = notification.userInfo?["levelIndex"] as? Int,
            let commandDataListInfo =
            notification.userInfo?["commandDataListInfo"] as? CommandDataListInfo else {
                fatalError("Not sent properly.")
        }

        guard let userId = AuthService.instance.currentUserId else {
            fatalError("User not logged in.")
        }

        DataService.instance.saveUserAddedCommands(userId: userId,
                                                   levelIndex: levelIndex,
                                                   saveName: "default",
                                                   commandDataListInfo: commandDataListInfo.toAnyObject())
    }

}
