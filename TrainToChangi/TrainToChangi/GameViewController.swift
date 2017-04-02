//
//  GameViewController.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 13/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
import SpriteKit

protocol GameVCTouchDelegate: class {
    func memoryIndex(at: CGPoint) -> Int?
}

class GameViewController: UIViewController {

    // VC is currently first responder, to be changed when we add other views.
    fileprivate var model: Model!
    fileprivate var logic: Logic!
    fileprivate var storage: Storage!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        registerObservers()
    }

    // Updates `model.runState` to `.running(isAnimating: true).
    @objc fileprivate func handleAnimationBegin(notification: Notification) {
        model.runState = .running(isAnimating: true)
    }

    // Updates `model.runState` accordingly depending on what is the current
    // `model.runState`.
    @objc fileprivate func handleAnimationEnd(notification: Notification) {
        if model.runState == .running(isAnimating: true) {
            model.runState = .running(isAnimating: false)
        } else if model.runState == .stepping {
            model.runState = .paused
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presentGameScene()
        // AudioPlayer.sharedInstance.playBackgroundMusic()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let embeddedVC = segue.destination as? EditorViewController {
            embeddedVC.model = self.model
        }

        if let embeddedVC = segue.destination as? ControlPanelViewController {
            embeddedVC.model = self.model
            embeddedVC.logic = self.logic
        }
    }

    @IBAction func exitButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: {
            AudioPlayer.sharedInstance.stopBackgroundMusic()
        })
    }

    /// Use GameScene to move/animate the game objects
    func presentGameScene() {
        let scene = GameScene(size: view.bounds.size)
        guard let skView = view as? SKView else {
            assertionFailure("View should be a SpriteKit View!")
            return
        }
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        scene.initLevelState(model.currentLevel)
    }

    private func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAnimationBegin(notification:)),
            name: Constants.NotificationNames.animationBegan, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAnimationEnd(notification:)),
            name: Constants.NotificationNames.animationEnded, object: nil)
    }
}

extension GameViewController: MapViewControllerDelegate {
    func initLevel(name: String?, storage: Storage) {
        self.storage = storage
        guard let name = name else {
            fatalError("Station must have a name!")
        }
        let levelIndex = indexOfStation(name: name)
        model = ModelManager(levelIndex: levelIndex,
                             levelData: Levels.levelData[levelIndex],
                             commandDataListInfo: storage.getUserAddedCommandsAsListInfo(levelIndex: levelIndex))
        logic = LogicManager(model: model)
    }

    private func indexOfStation(name: String) -> Int {
        let levelNames = Constants.StationNames.stationNames
        for (index, levelName) in levelNames.enumerated() {
            if levelName == name {
                return index
            }
        }
        preconditionFailure("StationName does not exist!")
    }
}
