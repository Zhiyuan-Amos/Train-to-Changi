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
    fileprivate var model: Model
    fileprivate var logic: Logic

    required init?(coder aDecoder: NSCoder) {
        // Change level by setting levelIndex here.
        model = ModelManager(levelData: LevelDataHelper.levelData(levelIndex: 0))
        logic = LogicManager(model: model)
        super.init(coder: aDecoder)
        registerObservers()
    }

    // Updates `model.runState` to `.running(isAnimating: true).
    @objc fileprivate func animationBegan(notification: Notification) {
        model.runState = .running(isAnimating: true)
    }

    // Updates `model.runState` accordingly depending on what is the current
    // `model.runState`.
    @objc fileprivate func animationEnded(notification: Notification) {
        if model.runState == .running(isAnimating: true) {
            model.runState = .running(isAnimating: false)
        } else if model.runState == .singleRun {
            model.runState = .paused
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presentGameScene()
        AudioPlayer.sharedInstance.playBackgroundMusic()
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
            self, selector: #selector(animationBegan(notification:)),
            name: Constants.NotificationNames.animationBegan, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(animationEnded(notification:)),
            name: Constants.NotificationNames.animationEnded, object: nil)
    }
}

extension GameViewController: MapViewControllerDelegate {
    func initLevel(name: String?) {
        model = ModelManager(levelData: LevelDataHelper.levelData(levelIndex: 0))
        logic = LogicManager(model: model)
    }
}
