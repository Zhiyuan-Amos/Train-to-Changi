//
//  Achievements.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 9/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

// Represents the different types of achievements a player can unlock.
enum AchievementsEnum: String {
    case completeLevelByTenSeconds
    case completeLevelOne
    case completeAllLevels
    case lostLevel
    case wonLevelOnFirstTry

    //stub
    static let allValues = [completeLevelByTenSeconds, completeLevelOne,
                            completeAllLevels, lostLevel, wonLevelOnFirstTry]

    func toAchivementName() -> String {
        switch self {
        case .completeLevelByTenSeconds:
            return "Fast Game: Complete Level By Ten Seconds"
        case .completeLevelOne:
            return "I Learn Things Fast: Complete Level One"
        case .completeAllLevels:
            return "SMRT Should Hire You: Complete All Levels"
        case .lostLevel:
            return "Train Delay Too Shag: Lost A Level"
        case .wonLevelOnFirstTry:
            return "Born A Champion: Won Level On First Try"
        }
    }
}
