//
//  MapViewController.swift
//  TrainToChangi
//
//  Created by zhongwei zhang on 3/27/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import FirebaseAuth

// View controller of the level map.

// Note that the view under MapViewControllerScene in 
// Storyboard must be set to custom class "SKView".
class MapViewController: UIViewController {

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // load .sks file

        guard let scene = GKScene(fileNamed: Constants.Map.mapSceneName) else {
            assertionFailure(Constants.Errors.mapSceneNameNotFound)
            return
        }
        // cast to custom MapScene
        guard let sceneNode = scene.rootNode as? MapScene else {
            assertionFailure(Constants.Errors.mapSceneNotSubclassed)
            return
        }
        sceneNode.mapSceneDelegate = self
        sceneNode.scaleMode = .aspectFill

        // cast own view so can present scene
        guard let skView = view as? SKView else {
            assertionFailure(Constants.Errors.gameViewNotSKView)
            return
        }
        skView.presentScene(sceneNode)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.SegueIds.startLevel?:
            guard let levelName = sender as? String else {
                assertionFailure(Constants.Errors.mapSceneToStartLevelStringNil)
                break
            }
            guard let gameVC = segue.destination as? GameViewController else {
                assertionFailure(Constants.Errors.wrongViewControllerLoaded)
                break
            }
            gameVC.initLevel(name: levelName)

        case Constants.SegueIds.cancelFromLevelSelectionWithSegue?:
            guard let _ = segue.destination as? LandingViewController else {
                assertionFailure(Constants.Errors.wrongViewControllerLoaded)
                break
            }

        default:
            assertionFailure(Constants.Errors.segueIdNotFound)
        }
    }

    @IBAction func cancelFromEndGameScreen(segue: UIStoryboardSegue) {
        AudioPlayer.sharedInstance.stopBackgroundMusic()
    }
}

// MARK: - MapSceneDelegate
extension MapViewController: MapSceneDelegate {
    func didTouchStation(name: String?) {
        guard let name = name else { return }
        performSegue(withIdentifier: Constants.SegueIds.startLevel, sender: name)
    }
}
