//
//  ScheduleTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-22.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

    @IBOutlet var scheduleLabel: UILabel!
    @IBOutlet var professorLabel: UILabel!
    @IBOutlet var sectionLabel: UILabel!
    @IBOutlet var semesterLabel: UILabel!
    @IBOutlet var cornerIconBackground: UIView!
    @IBOutlet var cornerIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cornerIconBackground.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
