//
//  DatePickerTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-30.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class DatePickerTableViewCell: UITableViewCell {

    @IBOutlet var datePicker: CustomDatePickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
