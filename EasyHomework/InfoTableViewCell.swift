//
//  InfoTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-07-14.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var semesterAndDateLabel: UILabel!
    @IBOutlet var feedbackLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
