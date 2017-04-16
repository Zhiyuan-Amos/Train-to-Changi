//
// Represents an achievement that the user can unlock.
//

class Achievement {
    let name: AchievementsEnum
    var isUnlocked: Bool

    // stub
    init(name: AchievementsEnum, isUnlocked: Bool) {
        self.name = name
        self.isUnlocked = isUnlocked
    }

}
