import UIKit

class AchievementCell: UITableViewCell {

    @IBOutlet weak var achievementImage: UIImageView!
    @IBOutlet weak var achievementText: UILabel!

    func setup(text: String, image: UIImage) {
        achievementText.text = text
        achievementImage.image = image
    }
}
