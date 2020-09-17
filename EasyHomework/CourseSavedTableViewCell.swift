//
//  CourseSavedTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-14.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class CourseSavedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var circleView: CircleView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
