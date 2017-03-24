import UIKit

struct Constants {
    // Struct is not meant to be initialised
    private init() {}

    struct ViewDimensions {
        static let bounds = UIScreen.main.bounds
        static let width = bounds.width
        static let height = bounds.height
        static let centerX = width / 2
        static let centerY = height / 2
    }

    struct Player {
        static let size = CGSize(width: 80, height: 80)
        static let position = CGPoint(x: ViewDimensions.width * 0.2, y: ViewDimensions.height / 2)
        static let zPosition = CGFloat(10)
    }

    struct Inbox {
        static let size = CGSize(width: 500, height: 100)
        static let position = CGPoint(x: ViewDimensions.width - size.width / 2,
                                      y: ViewDimensions.height - size.height / 2)
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
    
    struct Background {
        static let rows = 24
        static let columns = 32
        static let size = CGSize(width: 64, height: 64)
        static let tileSet = "Ground Tiles"
        static let tileGroup = "Grey Tiles"
    }

    struct Memory {
        static let labelFontSize = CGFloat(13)
        static let fillColor = UIColor.gray
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
