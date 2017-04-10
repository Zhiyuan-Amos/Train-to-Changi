//
//  AchievementsManager.swift
//  TrainToChangi
//
//  Created by Yong Zhi Yuan on 9/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

class AchievementsManager {
    static let sharedInstance = AchievementsManager()
    private var achievements: [Achievement] = [Achievement]()

    // stub
    private init() {
        for achievementEnum in AchievementsEnum.allValues {
            achievements.append(Achievement(name: achievementEnum, isUnlocked: false))
        }
    }

    // Call only when game is won.
    func updateAchievements(model: Model) {
        for achievement in achievements {
            if achievement.isUnlocked == false && isAchieved(model: model, achievement: achievement) {
                achievement.isUnlocked = true
            }
        }
    }

    private func isAchieved(model: Model, achievement: Achievement) -> Bool {
        switch achievement.name {
        case .completeLevelByTenSeconds:
            return model.getTimeElapsed() < 10
        case .completeLevelOne:
            return model.currentLevelIndex == 0
        case .completeAllLevels:
            return model.currentLevelIndex == 2
        case .lostLevel:
            return model.getNumLost() > 0
        case .wonLevelOnFirstTry:
            return model.getNumLost() == 0
        }
    }
}
