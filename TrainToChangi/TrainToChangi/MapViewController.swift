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

// View controller of the level map.

// Note that the view under MapViewControllerScene in 
// Storyboard must be set to custom class "SKView".
class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let scene = GKScene(fileNamed: "MapScene") else {
            assertionFailure("Did you rename the .sks file?")
            return
        }
        guard let sceneNode = scene.rootNode as? MapScene else {
            assertionFailure("Did you set custom class in MapView.sks?")
            return
        }
        sceneNode.scaleMode = .aspectFill

        guard let skView = view as? SKView else {
            assertionFailure("Did you set custom class of storyboard scene's view?")
            return
        }
        skView.presentScene(sceneNode)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
