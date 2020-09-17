//
//  ReviewContentTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-27.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class ReviewContentTableViewCell: UITableViewCell {

    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var thumbsUpButton: UIButton!
    @IBOutlet var thumbsDownButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
