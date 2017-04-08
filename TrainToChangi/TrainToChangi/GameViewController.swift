//
//  GameViewController.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 13/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, ResetGameDelegate {

    @IBOutlet weak var trainUIImage: UIImageView!

    fileprivate var model: Model!
    fileprivate var logic: Logic!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        registerObservers()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        // Makes sure that user is logged in.
        guard AuthService.instance.currentUserID != nil else {
            // show login viewcontroller
            performSegue(withIdentifier: "login", sender: nil)
            return
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerObservers()
        presentGameScene()
        animateTrain()
        AudioPlayer.sharedInstance.playBackgroundMusic()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let embeddedVC = segue.destination as? EditorViewController {
            embeddedVC.model = self.model
            embeddedVC.resetGameDelegate = self
        }

        if let embeddedVC = segue.destination as? ControlPanelViewController {
            embeddedVC.model = self.model
            embeddedVC.logic = self.logic
            embeddedVC.resetGameDelegate = self
        }
    }

    @IBAction func exitButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: {
            AudioPlayer.sharedInstance.stopBackgroundMusic()
        })
    }

    private func animateTrain() {
        var trainFrames = [UIImage]()
        for index in 0...Constants.UI.trainView.numTrainFrames {
            let frame = UIImage(named: "train_vert\(index)")!
            trainFrames.append(frame)
        }
        trainUIImage.animationImages = trainFrames
        trainUIImage.animationDuration = 1.5
        trainUIImage.startAnimating()
    }

    fileprivate func animateTrainWhenGameWon() {
        trainUIImage.stopAnimating()
        trainUIImage.animationImages = Constants.UI.trainView.gameWonTrainFrames
        trainUIImage.animationDuration = Constants.UI.trainView.gameWonTrainAnimationDuration
        trainUIImage.animationRepeatCount = Constants.UI.trainView.gameWonTrainAnimationRepeatCount
        trainUIImage.startAnimating()
    }

    fileprivate func displayEndGameScreen() {
        let storyboard = UIStoryboard(name: Constants.UI.mainStoryboardIdentifier, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: Constants.UI.endGameViewControllerIdentifier)
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.present(controller, animated: true, completion: nil)
    }

    func tryResetGame() {
        switch model.runState {
        case .paused, .lost:
            resetGame(isAnimating: false)
        default:
            break
        }
    }

    func resetGame(isAnimating: Bool) {
        model.resetPlayState()
        model.runState = .start // explicit assignment to trigger didSet
        logic.resetPlayState()

        NotificationCenter.default.post(Notification(
            name: Constants.NotificationNames.resetGameScene,
            object: nil, userInfo: ["isAnimating": isAnimating]))
    }

    /// Use GameScene to move/animate the game objects
    private func presentGameScene() {
        let scene = GameScene(model.currentLevel, size: view.bounds.size)
        guard let skView = view as? SKView else {
            assertionFailure("View should be a SpriteKit View!")
            return
        }
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
}

// MARK -- Event Handling
extension GameViewController {
    fileprivate func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAnimationBegin(notification:)),
            name: Constants.NotificationNames.animationBegan, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAnimationEnd(notification:)),
            name: Constants.NotificationNames.animationEnded, object: nil)
    }
}

extension GameViewController: MapViewControllerDelegate {
    func initLevel(name: String?) {
        guard let name = name else {
            fatalError("Station must have a name!")
        }
        let levelIndex = indexOfStation(name: name)
        model = ModelManager(levelIndex: levelIndex,
                             levelData: Levels.levelData[levelIndex])
        logic = LogicManager(model: model)
    }

    private func indexOfStation(name: String) -> Int {
        let levelNames = Constants.StationNames.stationNames
        guard let index = levelNames.index(where: { $0 == name }) else {
            preconditionFailure("StationName does not exist!")
        }

        return index
    }

    // Updates `model.runState` to `.running(isAnimating: true).
    @objc fileprivate func handleAnimationBegin(notification: Notification) {
        if model.runState == .running(isAnimating: false) {
            model.runState = .running(isAnimating: true)
        } else if model.runState == .stepping(isAnimating: false) {
            model.runState = .stepping(isAnimating: true)
        }
    }

    // Updates `model.runState` accordingly depending on what is the current
    // `model.runState`.
    @objc fileprivate func handleAnimationEnd(notification: Notification) {
        if model.runState == .running(isAnimating: true) {
            model.runState = .running(isAnimating: false)
        } else if model.runState == .stepping(isAnimating: true) {
            model.runState = .paused
        } else if model.runState == .won {
            animateTrainWhenGameWon()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Constants.UI.endGameScreenDisplayDelay), execute: {
                self.displayEndGameScreen()
            })
        }
    }
}
