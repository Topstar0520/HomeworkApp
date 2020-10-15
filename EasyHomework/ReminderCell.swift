//
//  ReminderCell.swift
//  B4Grad
//
//  Created by Pratik Patel on 1/9/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {

    @IBOutlet var imgIcon : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var imgCheck : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
