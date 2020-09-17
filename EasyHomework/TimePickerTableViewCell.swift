//
//  TimePickerTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-05.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class TimePickerTableViewCell: UITableViewCell {

    @IBOutlet var timePicker: CustomDatePickerView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
