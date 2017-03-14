//
//  Person.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

class Person {

    private var holdingValue: Int?
    
    func getHoldingValue() -> Int? {
        return holdingValue
    }

    func setHoldingValue(to newValue: Int?) {
        holdingValue = newValue
    }

}
