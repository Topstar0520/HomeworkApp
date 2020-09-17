//
//  CourseIntroTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-20.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class CourseIntroTableViewCell: UITableViewCell {
    
    @IBOutlet var topImageView: UIImageView!
    @IBOutlet var courseCodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.topImageView.layer.shadowColor = UIColor.black.cgColor
        self.topImageView.layer.shadowOpacity = 0.6
        self.topImageView.layer.shouldRasterize = true
        self.topImageView.layer.rasterizationScale = UIScreen.main.scale
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
