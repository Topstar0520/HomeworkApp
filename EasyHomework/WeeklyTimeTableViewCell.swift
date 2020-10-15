//
//  WeeklyTimeTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-04.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class WeeklyTimeTableViewCell: UITableViewCell {
    
    @IBOutlet var mondayAtLabel: UILabel!
    @IBOutlet var tuesdayAtLabel: UILabel!
    @IBOutlet var wednesdayAtLabel: UILabel!
    @IBOutlet var thursdayAtLabel: UILabel!
    @IBOutlet var fridayAtLabel: UILabel!
    @IBOutlet var mondayTimeButton: UIButton!
    @IBOutlet var tuesdayTimeButton: UIButton!
    @IBOutlet var wednesdayTimeButton: UIButton!
    @IBOutlet var thursdayTimeButton: UIButton!
    @IBOutlet var fridayTimeButton: UIButton!
    
    var arrayOfButtons = [UIButton]()
    var arrayOfLabels = [UILabel]()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        mondayAtLabel.isHidden = true
        tuesdayAtLabel.isHidden = true
        wednesdayAtLabel.isHidden = true
        thursdayAtLabel.isHidden = true
        fridayAtLabel.isHidden = true
        mondayTimeButton.isHidden = true
        tuesdayTimeButton.isHidden = true
        wednesdayTimeButton.isHidden = true
        thursdayTimeButton.isHidden = true
        fridayTimeButton.isHidden = true
        
        arrayOfLabels = [mondayAtLabel, tuesdayAtLabel, wednesdayAtLabel, thursdayAtLabel, fridayAtLabel]
        arrayOfButtons = [mondayTimeButton, tuesdayTimeButton, wednesdayTimeButton, thursdayTimeButton, fridayTimeButton]
        
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
