//
//  ReminderTitleCell.swift
//  B4Grad
//
//  Created by Pratik Patel on 15/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit

class ReminderTitleCell: UITableViewCell {

    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var imgIcon : UIImageView!
    @IBOutlet var subscribeImageView: UIImageView!
    @IBOutlet var subscribeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.accessoryView = UIImageView(image: UIImage(named: "disclosure indicator")) //since iOS13
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
