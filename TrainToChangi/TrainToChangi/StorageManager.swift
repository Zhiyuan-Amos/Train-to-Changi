//
//  StorageManager.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 4/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

class StorageManager {

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
