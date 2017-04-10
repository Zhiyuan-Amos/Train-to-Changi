import Foundation

class Achievement: NSObject, NSCoding {
    let name: AchievementsEnum
    var isUnlocked: Bool {
        willSet {
            guard isUnlocked == false && newValue == true else {
                fatalError("No other combinations of values should be allowed")
            }

            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.achievementUnlocked,
                                                         object: nil, userInfo: ["name": name]))
        }
    }

    // stub
    init(name: AchievementsEnum, isUnlocked: Bool) {
        self.name = name
        self.isUnlocked = isUnlocked
    }

    required init?(coder aDecoder: NSCoder) {
        guard let rawValue = aDecoder.decodeObject(forKey: "name") as? String,
            let name = AchievementsEnum(rawValue: rawValue) else {
                fatalError("Data was not encoded rightly.")
        }

        self.name = name
        self.isUnlocked = aDecoder.decodeBool(forKey: "isUnlocked")
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name.rawValue, forKey: "name")
        aCoder.encode(isUnlocked, forKey: "isUnlocked")
    }
}
