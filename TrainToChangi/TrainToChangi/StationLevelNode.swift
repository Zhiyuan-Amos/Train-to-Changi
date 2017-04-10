//
//  StationLevelNode.swift
//  TrainToChangi
//
//  Created by zhongwei zhang on 3/27/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit

protocol StationLevelNodeDelegate: class {
    func didTouchStation(name: String?)
}

class StationLevelNode: SKSpriteNode {
    weak var delegate: StationLevelNodeDelegate?

    init(_ node: SKSpriteNode, delegate: StationLevelNodeDelegate? = nil) {
        self.delegate = delegate
        super.init(texture: node.texture, color: node.color, size: node.size)
        self.name = node.name
        self.position = node.position
        self.isUserInteractionEnabled = true // Important. Else touch will not be detected
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouchStation(name: name)
    }
}
