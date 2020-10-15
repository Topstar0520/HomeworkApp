//
//  RepeatsTypeTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2018-08-07.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

class RepeatsTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var repeatsLabel: UILabel!
    @IBOutlet weak var repeatsImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
