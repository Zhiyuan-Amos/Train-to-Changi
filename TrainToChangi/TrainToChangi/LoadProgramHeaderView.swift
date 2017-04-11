//
//  LoadProgramHeaderView.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 11/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class LoadProgramHeaderView: UICollectionReusableView {
    @IBOutlet var loadProgramHeaderLabel: UILabel!

    func setLoadProgramHeaderLabel(labelText: String) {
        loadProgramHeaderLabel.text = labelText
    }
}
