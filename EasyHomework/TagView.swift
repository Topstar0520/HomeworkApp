//
//  TagView.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-20.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class TagView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 1.8
    }

}
