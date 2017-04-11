import UIKit

class AchievementCell: UITableViewCell {
    @IBOutlet weak var achievementImage: UIImageView!
    @IBOutlet weak var achievementText: UILabel!

    func setImage(image: UIImage) {
        achievementImage.image = image
    }

    func setText(text: String) {
        achievementText.text = text
    }
}
