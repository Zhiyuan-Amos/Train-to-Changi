import UIKit

struct Constants {
    // Struct is not meant to be initialised
    private init() {}

    struct Dimensions {
        static let bounds = UIScreen.main.bounds
        static let width = bounds.width
        static let height = bounds.height
        static let centerX = width / 2
        static let centerY = height / 2
    }

    struct Player {
        static let size = CGSize(width: 80, height: 80)
        static let position = CGPoint(x: Dimensions.width * 0.2, y: Dimensions.height / 2)
        static let zPosition = CGFloat(10)
    }

    struct Inbox {
        static let size = CGSize(width: 500, height: 100)
        static let position = CGPoint(x: Dimensions.width - size.width / 2,
            y: Dimensions.height - size.height / 2)
        static let color = UIColor.black
        static let goto = CGPoint(x: position.x - size.width / 2, y: position.y - size.height / 2)
    }

    struct Outbox {
        static let size = CGSize(width: 500, height: 100)
        static let position = CGPoint(x: size.width / 2, y: size.height / 2)
        static let color = UIColor.black
        static let goto = CGPoint(x: position.x + size.width / 2, y: position.y + size.height / 2)
        static let entryPosition = CGPoint(x: position.x + size.width / 2 - Box.size.width / 2, y: position.y)
    }

    struct Memory {

        // Specify how the memory are laid out in each level
        enum Layout {
            case twoByOne, twoByTwo, threeByThree

            var locations: [CGPoint] {
                let sX = Dimensions.centerX, sY = Dimensions.centerY
                let bW = Box.size.width, bH = Box.size.height
                switch self {
                case .twoByOne:
                    return [CGPoint(x: sX - bW / 2, y: sY), CGPoint(x: sX + bW / 2, y: sY)]
                case .twoByTwo:
                    return [CGPoint(x: sX - bW / 2, y: sY - bH / 2), CGPoint(x: sX + bW / 2, y: sY - bH / 2),
                            CGPoint(x: sX - bW / 2, y: sY + bH / 2), CGPoint(x: sX + bW / 2, y: sY + bH / 2)]
                case .threeByThree:
                    return [
                        CGPoint(x: sX - bW, y: sY - bH), CGPoint(x: sX, y: sY - bH), CGPoint(x: sX + bH, y: sY - bH),
                        CGPoint(x: sX - bW, y: sY),      CGPoint(x: sX, y: sY),      CGPoint(x: sX + bH, y: sY),
                        CGPoint(x: sX - bW, y: sY + bH), CGPoint(x: sX, y: sY + bH), CGPoint(x: sX + bH, y: sY + bH)]
                }
            }
        }
    }

    struct Box {
        static let size = CGSize(width: 100, height: 100)
    }

    struct NotificationNames {
        static let movePersonInScene = Notification.Name(rawValue: "movePersonInScene")
        static let initScene = Notification.Name(rawValue: "initScene")
    }

    struct UI {
        static let commandButtonInitialOffsetY: CGFloat = 40
        static let commandButtonOffsetY: CGFloat = 40
        static let commandButtonWidth: CGFloat = 100
        static let commandButtonHeight: CGFloat = 50

        static let commandCellIdentifier = "CommandCell"
    }
}
