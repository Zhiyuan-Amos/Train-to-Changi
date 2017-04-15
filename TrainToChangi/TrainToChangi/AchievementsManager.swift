import Foundation

class AchievementsManager {
    static let sharedInstance = AchievementsManager()
    fileprivate var achievements: [Achievement] = [Achievement]()
    private(set) var currentLevelUnlockedAchievements: [Achievement] = [Achievement]()
    var unlockedAchievements: [String] = []

    // Call only when game is won.
    func updateAchievements(model: Model) {
        guard let userId = AuthService.instance.currentUserId else {
            fatalError("User must be logged in!")
        }
        for achievement in achievements {
            if achievement.isUnlocked == false && isAchieved(model: model, achievement: achievement) {

                achievement.isUnlocked = true
                // Persist to Firebase the unlocking of this achievement
                let achievementString = achievement.name.rawValue
                DataService.instance.unlockAchievement(userId: userId,
                                                       achievementString: achievementString)
                if unlockedAchievements.contains(achievement.name.rawValue) {
                    continue
                }
                unlockedAchievements.append(achievement.name.rawValue)
                currentLevelUnlockedAchievements.append(achievement)
            }
        }
    }

    func updateOnLevelEnded() {
        currentLevelUnlockedAchievements.removeAll()
        unlockedAchievements.removeAll()
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

extension AchievementsManager: DataServiceLoadUnlockedAchievementsDelegate {
    func load(unlockedAchievements: [String]) {
        for achievementEnum in AchievementsEnum.allValues {
            let isUnlocked = unlockedAchievements.contains(achievementEnum.rawValue)
            achievements.append(Achievement(name: achievementEnum, isUnlocked: isUnlocked))
        }
    }
}
