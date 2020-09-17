//
//  FinalReminderTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-08-24.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit

class FinalReminderTableViewCell: UITableViewCell {
    
    @IBOutlet var textField: B4GradTextField!
    @IBOutlet var rhsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
