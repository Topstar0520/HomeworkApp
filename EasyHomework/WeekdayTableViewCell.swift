//
//  WeekdayTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-04.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class WeekdayTableViewCell: UITableViewCell {

    @IBOutlet var mondayButton: UIButton!
    @IBOutlet var tuesdayButton: UIButton!
    @IBOutlet var wednesdayButton: UIButton!
    @IBOutlet var thursdayButton: UIButton!
    @IBOutlet var fridayButton: UIButton!
    @IBOutlet var mondayCheckmark: UIImageView!
    @IBOutlet var tuesdayCheckmark: UIImageView!
    @IBOutlet var wednesdayCheckmark: UIImageView!
    @IBOutlet var thursdayCheckmark: UIImageView!
    @IBOutlet var fridayCheckmark: UIImageView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mondayButton.setBackgroundImage(UIImage(named: "ButtonBackgroundSelected"), for: .highlighted)
        tuesdayButton.setBackgroundImage(UIImage(named: "ButtonBackgroundSelected"), for: .highlighted)
        wednesdayButton.setBackgroundImage(UIImage(named: "ButtonBackgroundSelected"), for: .highlighted)
        thursdayButton.setBackgroundImage(UIImage(named: "ButtonBackgroundSelected"), for: .highlighted)
        fridayButton.setBackgroundImage(UIImage(named: "ButtonBackgroundSelected"), for: .highlighted)
        
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        
        for view in self.subviews {
            if view is UIScrollView {
                (view as? UIScrollView)!.delaysContentTouches = false
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.mondayCheckmark.image = #imageLiteral(resourceName: "Red X")
        self.tuesdayCheckmark.image = #imageLiteral(resourceName: "Red X")
        self.wednesdayCheckmark.image = #imageLiteral(resourceName: "Red X")
        self.thursdayCheckmark.image = #imageLiteral(resourceName: "Red X")
        self.fridayCheckmark.image = #imageLiteral(resourceName: "Red X")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
