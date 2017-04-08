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

protocol MapViewControllerDelegate: class {
    func initLevel(name: String?)
}

// View controller of the level map.

// Note that the view under MapViewControllerScene in 
// Storyboard must be set to custom class "SKView".
class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // load .sks file
        guard let scene = GKScene(fileNamed: "MapScene") else {
            assertionFailure("Did you rename the .sks file?")
            return
        }
        // cast to custom MapScene
        guard let sceneNode = scene.rootNode as? MapScene else {
            assertionFailure("Did you set custom class in MapView.sks?")
            return
        }
        sceneNode.mapSceneDelegate = self
        sceneNode.scaleMode = .aspectFill

        // cast own view so can present scene
        guard let skView = view as? SKView else {
            assertionFailure("Did you set custom class of storyboard scene's view?")
            return
        }
        skView.presentScene(sceneNode)
    }

    override func viewDidAppear(_ animated: Bool) {
        // Makes sure that user is logged in.
        guard FIRAuth.auth()?.currentUser != nil else {
            // show login viewcontroller
            performSegue(withIdentifier: "login", sender: nil)
            return
        }
        preloadCommandDataList()
    }

    // Speed up connection when loading in EditorVC.
    private func preloadCommandDataList() {
        guard let userID = AuthService.instance.currentUserID else {
            return
        }
        let ref = DataService.instance.usersRef.child(userID).child("commandDataListInfo")
        ref.observeSingleEvent(of: .value, with: { _ in
        }) { _ in
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.SegueIds.startLevel?:
            guard let levelName = sender as? String else {
                assertionFailure("sender should be a non-nil String")
                break
            }
            guard let gameVC = segue.destination as? GameViewController else {
                assertionFailure("Segue should point to GameViewController")
                break
            }
            gameVC.initLevel(name: levelName)
        case Constants.SegueIds.login?: break
        default:
            assertionFailure("Segue has a name unaccounted for")
        }
    }

    @IBAction func cancelFromEndGameScreen(segue: UIStoryboardSegue) {
        AudioPlayer.sharedInstance.stopBackgroundMusic()
    }
}

extension MapViewController: MapSceneDelegate {
    func didTouchStation(name: String?) {
        guard let name = name else { return }
        performSegue(withIdentifier: Constants.SegueIds.startLevel, sender: name)
    }
}
