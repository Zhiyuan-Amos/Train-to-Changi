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

    weak var mapSceneDelegate: MapSceneDelegate?

    override func didMove(to view: SKView) {
        // add camera so that can pan
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam)
        cam.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

        // replace placeholder SKSpriteNode with StationLevelNode nodes
        enumerateChildNodes(withName: Constants.Map.stationNameRegex, using: { node, _ in
            if let station = node as? SKSpriteNode {
                self.replace(station, with: StationLevelNode(station, delegate: self))
            }
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

    // replace empty SKSpriteNode with StationLevelNode
    private func replace(_ node: SKSpriteNode, with stationLevelNode: StationLevelNode) {
        node.removeFromParent()
        addChild(stationLevelNode)
    }
}

extension MapScene: StationLevelNodeDelegate {
    func didTouchStation(name: String?) {
        guard let name = name else { return }
        mapSceneDelegate?.didTouchStation(name: name)
    }
}
