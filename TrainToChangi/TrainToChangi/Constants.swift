import UIKit

struct Constants {
    // Struct is not meant to be initialised
    private init() {}

    struct Dimensions {
        static let bounds = UIScreen.main.bounds
        static let width = bounds.width
        static let height = bounds.height
    }

    struct Player {
        static let size = CGSize(width: 80, height: 80)
        static let position = CGPoint(x: Dimensions.width / 2, y: Dimensions.height / 2)
    }

    struct Inbox {
        static let size = CGSize(width: 100, height: 500)
        static let position = CGPoint(x: size.width / 2, y: size.height / 2)
        static let color = UIColor.black
        static let goto = CGPoint(x: size.width, y: size.height)
    }

    struct Outbox {
        static let size = CGSize(width: 100, height: 500)
        static let position = CGPoint(x: Dimensions.width - size.width / 2,
                                      y: Dimensions.height - size.height / 2)
        static let color = UIColor.black
        static let goto = CGPoint(x: Dimensions.width - size.width, y: Dimensions.height - size.height)
    }

    struct NotificationNames {
        static let movePersonInScene = Notification.Name(rawValue: "movePersonInScene")
    }
}
