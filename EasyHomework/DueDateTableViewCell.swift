//
//  DueDateTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-22.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class DueDateTableViewCell: UITableViewCell {

    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
