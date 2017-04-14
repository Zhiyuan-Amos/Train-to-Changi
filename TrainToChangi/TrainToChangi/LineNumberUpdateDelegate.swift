//
//  LineNumberUpdateDelegate.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 11/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

protocol LineNumberUpdateDelegate: class {
    func updateLineNumbers()
    func scrollToOffset(offset: CGPoint)
}
