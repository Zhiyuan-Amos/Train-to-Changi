//
//  CommandCell.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 17/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class CommandCell: UICollectionViewCell {
    private var imageView: UIImageView?

    //TODO: pass in frame
    func setImage(_ image: UIImage) {
        let frame =  CGRect(x: 0, y: 0, width: 100, height: 30)
        imageView = UIImageView(frame: frame)
        imageView?.image = image
        contentView.addSubview(imageView!)
    }
}
