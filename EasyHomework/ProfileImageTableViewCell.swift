//
//  ProfileImageTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-13.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class ProfileImageTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
