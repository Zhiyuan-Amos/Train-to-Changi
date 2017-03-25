//
//  StorageManager.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 16/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

class StorageManager {

    var currentSaveSlot = UserData()
    private var userDataFileName = "User1.plist"

    func storeUserData() {
        // save currentSaveSlot user data into file
    }

    func loadUserData() {
        // load from file into currentSaveSlot
    }

    func completeLevel(levelIndex: Int) {
        currentSaveSlot.completeLevel(levelIndex: levelIndex)
    }

//    func updateAddedCommands(levelIndex: Int, userAddedCommands: [CommandEnum]) {
//        currentSaveSlot.updateAddedCommands(levelIndex: levelIndex,
//                                            userAddedCommands: userAddedCommands)
//    }
//
//    /// Loads the levels list from the plist
//    func readLevelListFromDocument() -> [String: NSMutableDictionary] {
//        let fileURL = getDocumentURL(fileName: fileName)
//
//        var levelDictionary: [String: NSMutableDictionary]
//        levelDictionary = NSDictionary(contentsOf: fileURL) as? [String: NSMutableDictionary]
//            ?? initSaveFile(fileName: fileName)
//
//        return levelDictionary
//    }
//
//    func readLevelCompletion(levelName: String) -> Bool {
//        var levelDictionary = readLevelListFromDocument()
//        let level = levelDictionary[levelName]
//        let completion = level?["completedBefore"] as? Bool
//        return completion!
//    }
//
//    func readLevelInput(levelName: String) -> [Int] {
//        var levelDictionary = readLevelListFromDocument()
//        let level = levelDictionary[levelName]
//        let input = level?["input"] as? [Int]
//        return input!
//    }
//
//    func readLevelExpectedOutput(levelName: String) -> [Int] {
//        var levelDictionary = readLevelListFromDocument()
//        let level = levelDictionary[levelName]
//        let expectedOutput = level?["expectedOutput"] as? [Int]
//        return expectedOutput!
//    }
//
//    func readLevelDescription(levelName: String) -> String {
//        var levelDictionary = readLevelListFromDocument()
//        let level = levelDictionary[levelName]
//        let description = level?["expectedOutput"] as? String
//        return description!
//    }
//
//    func readLevelCommands(levelName: String) -> [String] {
//        var levelDictionary = readLevelListFromDocument()
//        let level = levelDictionary[levelName]
//        let commands = level?["command"] as? [String]
//        return commands!
//    }
//
//    func readSavedLevelCurrentCommands() -> [String] {
//        let path = Bundle.main.path(forResource: savedLevelFileName, ofType: "plist")!
//        let savedLevelDictionary = NSDictionary(contentsOfFile: path)!
//        return savedLevelDictionary["currentCommands"] as! [String]
//    }
//
//    func readSavedLevelInput() -> [Int] {
//        let path = Bundle.main.path(forResource: savedLevelFileName, ofType: "plist")!
//        let savedLevelDictionary = NSDictionary(contentsOfFile: path)!
//        return savedLevelDictionary["input"] as! [Int]
//    }
//
//    func readSavedLevelOutput() -> [Int] {
//        let path = Bundle.main.path(forResource: savedLevelFileName, ofType: "plist")!
//        let savedLevelDictionary = NSDictionary(contentsOfFile: path)!
//        return savedLevelDictionary["output"] as! [Int]
//    }
//
//    func readSavedLevelMemory() -> [Int] {
//        let path = Bundle.main.path(forResource: savedLevelFileName, ofType: "plist")!
//        let savedLevelDictionary = NSDictionary(contentsOfFile: path)!
//        return savedLevelDictionary["memory"] as! [Int]
//    }
//
//    func readSavedLevelPersonValue() -> Int {
//        let path = Bundle.main.path(forResource: savedLevelFileName, ofType: "plist")!
//        let savedLevelDictionary = NSDictionary(contentsOfFile: path)!
//        return savedLevelDictionary["personValue"] as! Int
//    }
//
//    func updateSavedLevelCurrentCommands(currentCommands: [String]) {
//        let path = Bundle.main.path(forResource: savedLevelFileName, ofType: "plist")!
//        let savedLevelDictionary = NSMutableDictionary(contentsOfFile: path)!
//        savedLevelDictionary["currentCommands"] = currentCommands
//        savedLevelDictionary.write(toFile: path, atomically: true)
//    }
//
//    func updateSavedLevelInput(input: [Int]) {
//        let path = Bundle.main.path(forResource: savedLevelFileName, ofType: "plist")!
//        let savedLevelDictionary = NSMutableDictionary(contentsOfFile: path)!
//        savedLevelDictionary["input"] = input
//        savedLevelDictionary.write(toFile: path, atomically: true)
//    }
//
//    func updateSavedLevelOutput(output: [Int]) {
//        let path = Bundle.main.path(forResource: savedLevelFileName, ofType: "plist")!
//        let savedLevelDictionary = NSMutableDictionary(contentsOfFile: path)!
//        savedLevelDictionary["output"] = output
//        savedLevelDictionary.write(toFile: path, atomically: true)
//    }
//
//    func updateSavedLevelMemory(memory: [Int]) {
//        let path = Bundle.main.path(forResource: savedLevelFileName, ofType: "plist")!
//        let savedLevelDictionary = NSMutableDictionary(contentsOfFile: path)!
//        savedLevelDictionary["memory"] = memory
//        savedLevelDictionary.write(toFile: path, atomically: true)
//    }
//
//    func updateSavedLevelPersonValue(personValue: Int) {
//        let path = Bundle.main.path(forResource: savedLevelFileName, ofType: "plist")!
//        let savedLevelDictionary = NSMutableDictionary(contentsOfFile: path)!
//        savedLevelDictionary["personValue"] = personValue
//        savedLevelDictionary.write(toFile: path, atomically: true)
//    }
//
//    private func getDocumentURL(fileName: String) -> URL {
//        // Get the URL of the Documents Directory
//        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//
//        // Get the URL for a file in the Documents Directory
//        let documentDirectory = urls[0]
//        let fileURL = documentDirectory.appendingPathComponent(fileName)
//        return fileURL
//    }
//
//    private func initSaveFile(fileName: String) -> [String: NSMutableDictionary] {
//        let path = Bundle.main.path(forResource: fileName, ofType: "plist")!
//        let levelDictionary = NSDictionary(contentsOfFile: path)! as! [String: NSMutableDictionary]
//
//        let fileURL = getDocumentURL(fileName: fileName)
//
//        saveDictionaryToFile(fileURL: fileURL, dictionary: levelDictionary)
//        return levelDictionary
//    }
//
//    @discardableResult
//    private func saveDictionaryToFile(fileURL: URL, dictionary: [String: NSMutableDictionary]) -> Bool {
//        let toSave = NSMutableDictionary()
//        toSave.setDictionary(dictionary)
//        let isSaved = toSave.write(to: fileURL, atomically: true)
//        return isSaved
//    }
//
//    func loadLevel(stationName: String) -> Level {
//        for level in PreloadedLevels.allLevels {
//            if level.levelName == stationName {
//                return level
//            }
//        }
//        fatalError("Level unable to be found")
//    }
}
