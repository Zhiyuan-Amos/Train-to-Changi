//
//  StorageManager.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 16/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

class StorageManager {

    private let pListExtension = ".plist"
    private let userDataKey = "userDataKey"

    // If userData has been saved, we read from file
    // else return new userData
    private(set) lazy var userData: UserData = {
        if let userData = self.load() {
            return userData
        }
        return UserData()
    }()

    func completeLevel(levelIndex: Int) {
        userData.completeLevel(levelIndex: levelIndex)
    }

    func updateAddedCommandsInfo(levelIndex: Int, commandDataListInfo: CommandDataListInfo) {
        userData.updateAddedCommandsInfo(levelIndex: levelIndex,
                                         commandDataListInfo: commandDataListInfo)
    }

    func hasCompletedLevel(levelIndex: Int) -> Bool {
        return userData.completedLevelIndexes.contains(levelIndex)
    }

    func save() {
        let fileNameToSave = Config.saveSlot.rawValue + pListExtension
        let url = getUrlOfFileInDocumentDirectory(fileName: fileNameToSave)
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)

        archiver.encode(userData, forKey: userDataKey)
        archiver.finishEncoding()

        let isSaveSuccessful = data.write(to: url, atomically: true)
        if !isSaveSuccessful {
            assertionFailure("Save failed!!")
        }
    }

    func load() -> UserData? {
        let fileNameToLoad = Config.saveSlot.rawValue + pListExtension
        let url = getUrlOfFileInDocumentDirectory(fileName: fileNameToLoad)

        guard let data = NSData(contentsOf: url) else {
            return nil
        }
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data as Data)

        let decoded = unarchiver.decodeObject(forKey: userDataKey)
        unarchiver.finishDecoding()

        let userData = decoded as? UserData
        return userData
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
