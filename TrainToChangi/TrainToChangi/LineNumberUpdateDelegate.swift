//
//  LineNumberUpdateDelegate.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 11/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

/**
 *  This delegate allows other view controllers to interact with
 *  the LineNumberViewController
 */
protocol LineNumberUpdateDelegate: class {

    // Call this to reload the line numbers in the collection view
    func updateLineNumbers()

    // Call this to scroll to a particular point in the collection view
    func scrollToOffset(offset: CGPoint)
}
