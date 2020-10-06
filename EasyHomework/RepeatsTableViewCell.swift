//
//  RepeatsTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2018-08-06.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

class RepeatsTableViewCell: UITableViewCell {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var repeatsLabel: UILabel!
    
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
