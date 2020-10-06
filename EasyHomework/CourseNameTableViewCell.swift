//
//  CourseNameTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-04-18.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit

class CourseNameTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: B4GradTextField!
    @IBOutlet weak var facultyButton: UIButton!
    @IBOutlet var facultyBgImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        facultyBgImageView.layer.cornerRadius = facultyBgImageView.frame.width / 2.0
        facultyBgImageView.layer.borderWidth = 1.0
        facultyBgImageView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 0.2012521404)
        facultyBgImageView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 0.2012521404)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
