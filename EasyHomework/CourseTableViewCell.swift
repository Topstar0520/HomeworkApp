//
//  CourseTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-04-16.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell { //in cellEditingVC

    @IBOutlet weak var circleView: CircleView!
    @IBOutlet weak var courseTitleLabel: UILabel!
    
    var courseTitle = "" {
        didSet {
            if (courseTitle.count <= 0 || courseTitle.caseInsensitiveCompare("course") == ComparisonResult.orderedSame) {
                self.courseTitleLabel.text = "Course"
                self.courseTitleLabel.textColor = UIColor.lightGray
            }else{
                self.courseTitleLabel.text         = courseTitle
                self.courseTitleLabel.textColor    = UIColor.white
            }
        }
    }
    
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
