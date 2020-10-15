//
//  SelectTagCollectionViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-29.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class SelectTagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var tagIconImageView: UIImageView!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var borderView: UIView!
 
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.frame.size.height / 2.0
        self.borderView.layer.cornerRadius = self.frame.size.height / 2.0
    }
    
}
