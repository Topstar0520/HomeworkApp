//
//  PickerTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-27.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {

    @IBOutlet var pickerView: CustomPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
