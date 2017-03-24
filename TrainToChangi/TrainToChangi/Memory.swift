//
// Created by zhongwei zhang on 3/22/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

struct Memory {
    typealias CGP = CGPoint

    // Specify how the memory are laid out in each level. Each CGPoint is the center of the memory slot.
    // Add case and specify in `locations` to add more memory layouts.
    enum Layout {
        case twoByOne, twoByTwo, threeByThree

        var locations: [CGPoint] {
            // sX, sY are the x and y of the screen's center.
            let centerX = Constants.ViewDimensions.centerX, centerY = Constants.ViewDimensions.centerY
            // bW, bH are the width and height of Box
            let boxWidth = Constants.Box.size.width, boxHeight = Constants.Box.size.height

            switch self {

            case .twoByOne:
                return [CGP(centerX - boxWidth / 2, centerY), CGP(centerX + boxWidth / 2, centerY)]

            case .twoByTwo:
                let x1 = centerX - boxWidth / 2, x2 = centerX + boxWidth / 2
                let y1 = centerY - boxHeight / 2, y2 = centerY + boxHeight / 2

                return [CGP(x1, y1), CGP(x2, y1),
                        CGP(x1, y2), CGP(x2, y2)]

            case .threeByThree:
                let x1 = centerX - boxWidth, x2 = centerX, x3 = centerX + boxHeight
                let y1 = centerY - boxHeight, y2 = centerY, y3 = centerY + boxHeight

                return [CGP(x1, y1), CGP(x2, y1), CGP(x3, y1),
                        CGP(x1, y2), CGP(x2, y2), CGP(x3, y2),
                        CGP(x1, y3), CGP(x2, y3), CGP(x3, y3)]
            }
        }
    }
}

extension CGPoint {
    // make CGPoint init less verbose
    // swiftlint:disable variable_name
    init(_ x: CGFloat, _ y: CGFloat) {
        self.x = x
        self.y = y
    }
}
