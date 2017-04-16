import UIKit

extension EndGameViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "achievement"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                       for: indexPath) as? AchievementCell else {
            fatalError("Cell not assigned the proper view subclass!")
        }

        cell.setText(text: achievements.currentLevelUnlockedAchievements[indexPath.item].name.toAchievementName())
        cell.setImage(image: UIImage(named: achievements.currentLevelUnlockedAchievements[indexPath.item].name.toImagePath())!)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return achievements.currentLevelUnlockedAchievements.count
    }
}

extension EndGameViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "You have unlocked these achievements:"
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
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
        cell.setText(text: achievements[indexPath.item].name.toAchievementName())
        cell.setImage(image: UIImage(named: achievements[indexPath.item].name.toImagePath())!)
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
