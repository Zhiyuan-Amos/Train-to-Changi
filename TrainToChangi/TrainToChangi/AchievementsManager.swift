//
// A singleton class that manages the achievements in game. This class is implemented
// as a singleton because the application only requires one instance of this object.
// For example, LandingViewVC requires this class to initialise the achievements
// that the user has. Also, EndGameVC requires this class to present to user
// which achievements he has unlocked in the current level. Having multiple
// instances of this class can cause the achievements to be unsynchronised.
// Another possible implementation would be to make `ApplicationManager` (a higher
// level class) to be a Singleton instead, and make AchievementsManager a normal class
// which should only be accessed through `ApplicationManager`. However, this does
// not seem to be any better than the current way of implementation. 
//

class AchievementsManager {
    static let sharedInstance = AchievementsManager()
    fileprivate var achievements: [Achievement] = [Achievement]()
    private(set) var currentLevelUnlockedAchievements: [Achievement] = [Achievement]()

    // This method can be called any time during the game.
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

                if currentLevelUnlockedAchievements.contains(where: { $0.name == achievement.name }) {
                    continue
                }
                currentLevelUnlockedAchievements.append(achievement)
            }
        }
    }

    // This method must be called at the end of each level. This is because
    // `currentLevelUnlockedAchievements` is the data source for EndGameVC
    // to present the achievements that have been unlocked in the current level.
    func updateOnLevelEnded() {
        currentLevelUnlockedAchievements.removeAll()
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
