//
//  MapScene.swift
//  TrainToChangi
//
//  Created by zhongwei zhang on 3/27/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit
import GameplayKit

// Scene that presents the railway map, which represents the levels and progress of player.
// Interface is mostly drawn using the MapScene.sks file. The map can be much bigger than
// the camera, just pan and navigate around the map.

// Note that in the MapScene.sks file, the custom class must be set to "MapScene".
class MapScene: SKScene {
    var cam: SKCameraNode!

    override func didMove(to view: SKView) {
        //Inside of didMoveToView

        cam = SKCameraNode() //initialize and assign an instance of SKCameraNode to the cam variable.
        //cam.setScale(1) //the scale sets the zoom level of the camera on the given position

        self.camera = cam //set the scene's camera to reference cam
        self.addChild(cam) //make the cam a childElement of the scene itself.

        //position the camera on the gamescene.
        cam.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)

        camera?.position.x -= location.x - previousLocation.x
        camera?.position.y -= location.y - previousLocation.y
    }
}
