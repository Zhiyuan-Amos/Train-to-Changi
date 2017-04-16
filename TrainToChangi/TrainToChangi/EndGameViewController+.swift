import UIKit

extension EndGameViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = Constants.UI.achievementTableViewCellIdentifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                       for: indexPath) as? AchievementCell else {
            fatalError(Constants.Errors.cellNotAssignedCorrectViewSubclass)
        }

        let index = indexPath.item
        let text = achievements.currentLevelUnlockedAchievements[index].name.toAchievementName()
        guard let image = UIImage(named: achievements.currentLevelUnlockedAchievements[index].name.toImagePath()) else {
            fatalError(Constants.Errors.achievementImageNotSet)
        }

        cell.setup(text: text, image: image)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return achievements.currentLevelUnlockedAchievements.count
    }
}

extension EndGameViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.UI.Achievement.headerTitle
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.UI.Achievement.headerHeight
    }
}

extension AchievementsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "achievement"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                       for: indexPath) as? AchievementCell else {
                                                        fatalError("Cell not assigned the proper view subclass!")
        }
        cell.setup(text: achievements[indexPath.item].name.toAchievementName(),
                   image: UIImage(named: achievements[indexPath.item].name.toImagePath())!)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(achievements.count)
        return achievements.count
    }
}

extension AchievementsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "You have unlocked these achievements:"
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
