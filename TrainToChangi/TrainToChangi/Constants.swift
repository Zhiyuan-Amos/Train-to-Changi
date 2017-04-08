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
        static let pickupOffsetY = CGFloat(-50)
    }

    struct Inbox {
        static let size = CGSize(width: 420, height: 60)
        static let position = CGPoint(x: 575,
                                      y: ViewDimensions.height - size.height / 2 - 40)
        static let color = UIColor.black
        static let goto = CGPoint(x: position.x - size.width / 2, y: position.y - size.height / 2)
        static let imagePadding: CGFloat = 10
        static let payloadStartingX = position.x - size.width / 2 + Payload.size.width / 2 + imagePadding
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
        static let memoryTexture = SKTexture(imageNamed: "memory")
        static let memorySelectTexture = SKTexture(imageNamed: "memory-select")
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

    struct Jedi {
        static let height = 100
        static let width = 50
        static let positionX = 300
        static let positionY = 700

        static let texture = SKTexture(imageNamed: "jedi_01")
    }

    struct SpeechBubble {
        static let height = 150
        static let width = 250
        static let positionX = 350
        static let positionY = 580

        static let fontName = "HelveticaNeue-Bold"
        static let fontSize: CGFloat = 14
        static let fontColor = UIColor.black

        static let texture = SKTexture(imageNamed: "speech")
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

    struct Concurrency {
        static let serialQueue = "serialQueue"
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
        static let userAddCommandEvent = Notification.Name(rawValue: "userAddCommandEvent")
        static let userDeleteCommandEvent = Notification.Name(rawValue: "userDeleteCommandEvent")
        static let userResetCommandEvent = Notification.Name(rawValue: "userResetCommandEvent")
        static let userScrollEvent = Notification.Name(rawValue: "userScrollEvent")
        static let updateCommandIndexEvent = Notification.Name(rawValue: "updateCommandIndexEvent")
        static let cancelUpdateCommandIndexEvent = Notification.Name(rawValue: "cancelUpdateCommandIndexEvent")
        static let userSelectedIndexEvent = Notification.Name(rawValue: "userSelectedIndexEvent")
        static let endOfCommandExecution = Notification.Name(rawValue: "endOfCommandExecution")
        static let toggleSpeechEvent = Notification.Name(rawValue: "toggleSpeechEvent")
        static let sliderShifted = Notification.Name(rawValue: "sliderShifted")
    }

    struct SegueIds {
        static let startLevel = "startLevel"
        static let login = "login"
    }

    // swiftlint:disable type_name
    struct UI {
        static let mainStoryboardIdentifier = "Main"
        static let endGameViewControllerIdentifier = "EndGameViewController"

        static let commandButtonInitialOffsetY: CGFloat = 20
        static let commandButtonOffsetY: CGFloat = 30
        static let commandButtonHeight: CGFloat = 40

        static let commandButtonWidthShort: CGFloat = 40
        static let commandButtonWidthMid: CGFloat = 60
        static let commandButtonWidthLong: CGFloat = 80
        static let commandIndexWidth: CGFloat = 20

        static let dragDropCollectionViewCellIdentifier = "CommandCell"
        static let lineNumberCollectionViewCellIdentifier = "LineNumberCell"

        static let numberOfSectionsInCollectionView = 1

        static let topEdgeInset: CGFloat = 10
        static let rightEdgeInset: CGFloat = 10

        static let minimumLineSpacingForSection: CGFloat = 0
        static let minimumInteritemSpacingForSection: CGFloat = 0

        static let collectionCellWidth: CGFloat = 100
        static let collectionCellHeight: CGFloat = 40

        static let programCounterOffsetX: CGFloat = 5

        static let userSelectedIndexNotificationDelay = 200
        static let endGameScreenDisplayDelay = 2

        struct arrowView {
            static let originX: CGFloat = 5
            static let originY: CGFloat = 5
            static let arrowWidth: CGFloat = 30
        }

        struct trainView {
            static let numTrainFrames = 7
            static let trainAnimationDuration = 1.5

            static let gameWonTrainFrames = [UIImage(named: "train_vert0")!, UIImage(named: "train_vert8")!]
            static let gameWonTrainAnimationDuration = 0.5
            static let gameWonTrainAnimationRepeatCount = 3
        }

    }

    struct Time {
        static let oneMillisecond: UInt32 = 100000
    }

    struct Animation {
        static let moveToConveyorBeltDuration = 0.67
        static let moveToMemoryDuration = 0.33

        static let moveConveyorBeltVector = CGVector(dx: -Payload.size.width - Inbox.imagePadding, dy: 0)
        static let moveConveyorBeltDuration = 0.7

        static let afterInboxStepVector = CGVector(dx: 0, dy: -60)
        static let afterInboxStepDuration = 0.17

        static let holdingToOutboxDuration = 0.33

        static let discardHoldingValueDuration = 0.17
        static let holdingValueToMemoryDuration = 0.17

        static let programCounterMovementDuration = 0.1

        static let conveyorBeltFrames = [SKTexture(imageNamed: "conveyor-belt-1"),
                                         SKTexture(imageNamed: "conveyor-belt-2"),
                                         SKTexture(imageNamed: "conveyor-belt-3")]
        static let conveyorBeltTimePerFrame = 0.017
        static let conveyorBeltAnimationCount = 4
        static let inboxAnimationKey = "inboxMoving"
        static let outboxAnimationKey = "outboxMoving"

        static let defaultSpeed: CGFloat = 0.33
        static let speedRange: CGFloat = 1 - defaultSpeed
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
            static let add = CommandData.add(memoryIndex: 0)
            static let copyTo = CommandData.copyTo(memoryIndex: 0)
            static let copyFrom = CommandData.copyFrom(memoryIndex: 0)
        }
    }
}
