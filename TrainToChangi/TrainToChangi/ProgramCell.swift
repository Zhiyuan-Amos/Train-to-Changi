//
//  ProgramCell.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 11/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class ProgramCell: UICollectionViewCell {

    @IBOutlet weak var programCellLabel: UILabel!

    func setProgramCellLabel(programName: String) {
        programCellLabel.text = programName
    }
}
