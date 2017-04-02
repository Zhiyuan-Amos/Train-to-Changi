//
//  StorageManager.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 16/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

class StorageManager: Storage {

    private let pListExtension = ".plist"
    private let userDataKey = "userDataKey"

    // Hardcode in until we implement multiple slots with UserDefaults.
    private let saveSlotRawValue = "SlotOne"

    init() {
        initNotification()
    }

    // If userData has been saved, we read from file
    // else return new userData
    private lazy var userData: UserData = {
        if let userData = self.load() {
            return userData
        }
        return UserData()
    }()

    func hasCompletedLevel(levelIndex: Int) -> Bool {
        return userData.completedLevelIndexes.contains(levelIndex)
    }

    func getUserAddedCommandsAsListInfo(levelIndex: Int) -> CommandDataListInfo? {
        return userData.getAddedCommands(levelIndex: 0)
    }

    func save() {
        let fileNameToSave = saveSlotRawValue + pListExtension
        let url = getUrlOfFileInDocumentDirectory(fileName: fileNameToSave)
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)

        archiver.encode(userData, forKey: userDataKey)
        archiver.finishEncoding()

        let isSaveSuccessful = data.write(to: url, atomically: true)
        assert(isSaveSuccessful, "Save cannot fail!")
    }

    private func load() -> UserData? {
        let fileNameToLoad = saveSlotRawValue + pListExtension
        let url = getUrlOfFileInDocumentDirectory(fileName: fileNameToLoad)

        guard let data = NSData(contentsOf: url) else {
            // File not found.
            return nil
        }
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data as Data)

        let decoded = unarchiver.decodeObject(forKey: userDataKey)
        unarchiver.finishDecoding()

        guard let userData = decoded as? UserData else {
            // We fatalError here instead of asserting and returning nil to prevent
            // user's saved file from being overwritten because of a bug
            // in code potentially introduced due to an update.
            fatalError("Loading cannot fail if file is found.")
        }
        return userData
    }

    // Deletes the saved userData file.
    private func clearUserData() {
        let fileNameToLoad = saveSlotRawValue + pListExtension
        let url = getUrlOfFileInDocumentDirectory(fileName: fileNameToLoad)
        // TODO: Improve handling
        try? FileManager.default.removeItem(at: url)
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

        updateAddedCommandsInfo(levelIndex: levelIndex,
                                commandDataListInfo: commandDataListInfo)
    }

    private func updateAddedCommandsInfo(levelIndex: Int, commandDataListInfo: CommandDataListInfo) {
        userData.updateAddedCommandsInfo(levelIndex: levelIndex,
                                         commandDataListInfo: commandDataListInfo)
    }

    // Receive notification that level is completed, then call this func.
    private func completeLevel(levelIndex: Int) {
        userData.completeLevel(levelIndex: levelIndex)
    }

    private func getUrlOfFileInDocumentDirectory(fileName: String) -> URL {
        // Get the URL of the Documents Directory
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // Get the URL for a file in the Documents Directory
        let documentDirectory = urls[0]
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        return fileURL
    }

}
