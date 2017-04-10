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

    // The bound that the camera is allowed to move in.
    // Hardcoded values because it's not possible to set a bound based on the .sks file.
    // With this bound, when camera moves, check it's future position and drag it back if
    // it will be out of bound.
    private var bound: CGRect {
        return CGRect (
            x: anchorPoint.x - 50, y: anchorPoint.y - 200,
            width: Constants.ViewDimensions.width * 1.5, height: Constants.ViewDimensions.height * 0.8
        )
    }

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

        guard let camera = camera else {
            assertionFailure("camera was not set"); return
        }

        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)

        let camFuturePosition = CGPoint(
            x: camera.position.x - location.x + previousLocation.x,
            y: camera.position.y - location.y + previousLocation.y
        )

        if bound.contains(camFuturePosition) {
            camera.position = camFuturePosition
        } else {
            camera.position = draggedBackPosition(from: camFuturePosition)
        }
    }

    // replace empty SKSpriteNode with StationLevelNode
    private func replace(_ node: SKSpriteNode, with stationLevelNode: StationLevelNode) {
        node.removeFromParent()
        addChild(stationLevelNode)
    }

    // Set camera back if it is outside its cage
    private func draggedBackPosition(from point: CGPoint) -> CGPoint {
        /*
         | 1 | 2 | 3 |
         -------------
         | 4 | x | 5 |
         -------------
         | 6 | 7 | 8 |

         */
        let offset = CGFloat(30)
        let upperY = bound.maxY - offset
        let lowerY = bound.minY + offset

        if point.x < bound.minX {
            let x = bound.minX + offset

            if point.y > bound.maxY { // 1
                return CGPoint(x: x, y: upperY)
            } else if point.y < bound.minY { // 6
                return CGPoint(x: x, y: lowerY)
            } else { // 4
                return CGPoint(x: x, y: point.y)
            }

        } else if point.x > bound.maxX {
            let x = bound.maxX - offset

            if point.y > bound.maxY { // 3
                return CGPoint(x: x, y: upperY)
            } else if point.y < bound.minY { // 8
                return CGPoint(x: x, y: lowerY)
            } else { // 5
                return CGPoint(x: x, y: point.y)
            }

        } else {
            if point.y > bound.maxY { // 2
                return CGPoint(x: point.x, y: upperY)
            } else { // 7
                return CGPoint(x: point.x, y: lowerY)
            }
        }
    }
}

extension MapScene: StationLevelNodeDelegate {
    func didTouchStation(name: String?) {
        guard let name = name else { return }
        mapSceneDelegate?.didTouchStation(name: name)
    }
}
