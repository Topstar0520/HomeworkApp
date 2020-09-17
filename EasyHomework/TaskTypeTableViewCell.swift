//
//  TaskTypeTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-04-15.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit

class TaskTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var taskImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
