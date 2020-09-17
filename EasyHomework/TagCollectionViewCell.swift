//
//  TagCollectionViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-08.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var tagImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.frame.size.height / 1.8
    }
    
}
