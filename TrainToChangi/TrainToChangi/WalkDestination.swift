//
// Created by zhongwei zhang on 4/15/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

// Stores the location that can be reached by player sprite.
enum WalkDestination {
    case inbox, outbox, memory(layout: Memory.Layout, index: Int, action: Memory.Action)

    var point: CGPoint {
        switch self {
        case .inbox:
            return Constants.Inbox.goto
        case .outbox:
            return Constants.Outbox.goto
        case let .memory(layout, index, _):
            return layout.locations[index]
        }
    }
}
