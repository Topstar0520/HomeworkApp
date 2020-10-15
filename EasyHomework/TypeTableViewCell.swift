//
//  TypeTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-04-16.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit

class TypeTableViewCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var taskImageView: UIImageView!
    
    var taskType = "" {
        didSet {
            if (taskType.count <= 0 || taskType.caseInsensitiveCompare("type") == ComparisonResult.orderedSame) {
                self.taskLabel.text = "Type"
                self.taskLabel.textColor = UIColor.lightGray
            }else{
                self.taskLabel.text         = taskType
                self.taskLabel.textColor    = UIColor.white
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
