//
//  MapScene.swift
//  TrainToChangi
//
//  Created by zhongwei zhang on 3/27/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol MapSceneDelegate: class {
    func didTouchStation(name: String?)
}

// Scene that presents the railway map, which represents the levels and progress of player.
// Interface is mostly drawn using the MapScene.sks file. The map can be much bigger than
// the camera, just pan and navigate around the map.

// Note that in the MapScene.sks file, the custom class must be set to "MapScene".
// All station nodes must be named ***Station, e.g. ChangiStation
class MapScene: SKScene {
    private var cam: SKCameraNode!

    // can't use "delegate" as name as Swift forbids overriding inherited properties
    weak var agent: MapSceneDelegate?

    override func didMove(to view: SKView) {
        // add camera so that can pan
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam)
        cam.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

        // replace empty placeholder SKNode with MapStation nodes
        enumerateChildNodes(withName: "^\\w+Station$", using: { node, _ in
            self.replace(node, with: MapStation(node, delegate: self))
        })
    }

    // pan to move the camera
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)

        camera?.position.x -= location.x - previousLocation.x
        camera?.position.y -= location.y - previousLocation.y
    }

    // replace empty SKNode with MapStation
    private func replace(_ one: SKNode, with another: MapStation) {
        one.removeFromParent()
        addChild(another)
    }
}

extension MapScene: MapStationDelegate {
    func didTouchStation(name: String?) {
        guard let name = name else { return }
        agent?.didTouchStation(name: name)
    }
}
