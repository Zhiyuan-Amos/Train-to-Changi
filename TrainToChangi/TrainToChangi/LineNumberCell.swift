//
//  LineNumberCell.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 2/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class LineNumberCell: UICollectionViewCell {

    @IBOutlet weak var lineNumberLabel: UILabel!

    func setLineNumberLabel(index: Int) {
        lineNumberLabel.text = "\(index)."
        lineNumberLabel.font = Constants.UI.LineNumber.font
        lineNumberLabel.textColor = Constants.UI.LineNumber.textColor
        lineNumberLabel.textAlignment = NSTextAlignment.center
    }
}
