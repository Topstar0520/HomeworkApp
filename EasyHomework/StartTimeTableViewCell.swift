//
//  StartTimeTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2018-01-24.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

class StartTimeTableViewCell: UITableViewCell {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var startTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
