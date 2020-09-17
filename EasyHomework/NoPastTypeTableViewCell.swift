//
//  NoPastTypeTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-08-31.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit

class NoPastTypeTableViewCell: UITableViewCell {

    @IBOutlet var typeImageView: UIImageView!
    @IBOutlet var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
