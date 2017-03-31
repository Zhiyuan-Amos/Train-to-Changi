import UIKit
import SpriteKit

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
        static let size = CGSize(width: 420, height: 60)
        static let position = CGPoint(x: 575,
                                      y: ViewDimensions.height - size.height / 2 - 40)
        static let color = UIColor.black
        static let goto = CGPoint(x: position.x - size.width / 2, y: position.y - size.height / 2)
        static let imagePadding: CGFloat = 10
    }

    struct Outbox {
        static let size = CGSize(width: 420, height: 60)
        static let position = CGPoint(x: 400, y: 140)
        static let color = UIColor.black
        static let goto = CGPoint(x: position.x + size.width / 2, y: position.y + size.height / 2)
        static let entryPosition = CGPoint(x: position.x + size.width / 2
            - Payload.size.width / 2 - 10, y: position.y + Payload.imageOffsetY)
        static let imagePadding: CGFloat = 10
    }

    struct Background {
        static let rows = 12
        static let columns = 16
        static let size = CGSize(width: 64, height: 64)
        static let tileSet = "Ground Tiles"
        static let tileGroup = "Grey Tiles"
    }

    struct Memory {
        static let labelFontSize = CGFloat(13)
        static let labelOffsetX: CGFloat = 15
        static let labelOffsetY: CGFloat = -20
        static let fontColor = UIColor.darkGray
        static let size = CGSize(width: 60, height: 60)
    }

    struct Payload {
        static let imageName = "box"
        static let labelName = "payload label"
        static let labelOffsetY: CGFloat = -5
        static let imageOffsetY: CGFloat = 35
        static let fontName = "HelveticaNeue-Bold"
        static let fontSize: CGFloat = 18
        static let fontColor = UIColor.darkGray
        static let size = CGSize(width: 40, height: 40)
        // Rotate a random value from 0 degrees to 5 degrees
        static var rotationAngle: CGFloat {
            return CGFloat((.pi / 36) * drand48())
        }
    }

    struct Map {
        static let stationImage = "station"
        // station nodes should be named in .sks file as SomethingStation, like KentRidgeStation
        static let stationNameRegex = "^\\w+Station$"
        static let stationNodeSize = CGSize(width: 200, height: 200)
    }

    struct StationNames {
        static let stationNames = ["KentRidgeStation", "CityHallStation", "ChangiStation"]
    }

    struct NotificationNames {
        static let moveProgramCounter = Notification.Name(rawValue: "moveProgramCounter")
        static let commandDataListUpdate = Notification.Name(rawValue: "commandDataListUpdate")
        static let movePersonInScene = Notification.Name(rawValue: "movePersonInScene")
        static let initScene = Notification.Name(rawValue: "initScene")
        static let animationBegan = Notification.Name(rawValue: "animationBegan")
        static let animationEnded = Notification.Name(rawValue: "animationEnded")
        static let runStateUpdated = Notification.Name(rawValue: "runStateUpdated")
        static let resetGameScene = Notification.Name(rawValue: "resetGameScene")
    }

    struct SegueIds {
        static let startLevel = "startLevel"
    }

    // swiftlint:disable type_name
    struct UI {
        static let commandButtonInitialOffsetY: CGFloat = 20
        static let commandButtonOffsetY: CGFloat = 40
        static let commandButtonHeight: CGFloat = 50

        static let commandButtonWidthShort: CGFloat = 60
        static let commandButtonWidthMid: CGFloat = 80
        static let commandButtonWidthLong: CGFloat = 100
        static let commandIndexWidth: CGFloat = 20

        static let collectionViewCellIdentifier = "CommandCell"

        static let numberOfSectionsInCollectionView = 1

        static let topEdgeInset: CGFloat = 10
        static let rightEdgeInset: CGFloat = 30

        static let minimumLineSpacingForSection: CGFloat = 0
        static let minimumInteritemSpacingForSection: CGFloat = 0

        static let collectionCellWidth: CGFloat = 160
        static let collectionCellHeight: CGFloat = 40

        static let arrowWidth: CGFloat = 30

        static let programCounterOffsetX: CGFloat = 5
    }

    struct Logic {
        static let oneMillisecond: UInt32 = 100000
    }

    struct Animation {
        static let moveToConveyorBeltDuration = 2.0
        static let moveToMemoryDuration = 1.0

        static let moveConveyorBeltVector = CGVector(dx: -Payload.size.width - Inbox.imagePadding, dy: 0)
        static let moveConveyorBeltDuration = 0.7

        static let afterInboxStepVector = CGVector(dx: 0, dy: -60)
        static let afterInboxStepDuration = 0.5

        static let holdingToOutboxDuration = 1.0

        static let discardHoldingValueDuration = 0.5
        static let holdingValueToMemoryDuration = 0.5

        static let programCounterMovementDuration = 0.1

        static let conveyorBeltFrames = [SKTexture(imageNamed: "conveyor-belt-1"),
                                         SKTexture(imageNamed: "conveyor-belt-2"),
                                         SKTexture(imageNamed: "conveyor-belt-3")]
        static let conveyorBeltTimePerFrame = 0.05
        static let conveyorBeltAnimationCount = 4
        static let inboxAnimationKey = "inboxMoving"
        static let outboxAnimationKey = "outboxMoving"
    }

    struct Audio {
        static let bgMusic = "main-track"
    }

    struct LevelDataHelper {
        static let newLine = "\n"

        struct Commands {
            static let inbox = CommandData.inbox
            static let outbox = CommandData.outbox
            static let jump = CommandData.jump
            static let add = CommandData.add(memoryIndex: nil)
            static let copyTo = CommandData.copyTo(memoryIndex: nil)
            static let copyFrom = CommandData.copyFrom(memoryIndex: nil)
        }
    }
}
