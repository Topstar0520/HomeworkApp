//
//  EndTimeTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2018-01-24.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

class EndTimeTableViewCell: UITableViewCell {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var endTimeLabel: UILabel!
    
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
