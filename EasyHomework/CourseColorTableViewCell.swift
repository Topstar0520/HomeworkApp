//
//  CourseColorTableViewCell.swift
//  B4Grad
//
//  Created by Sunil Zalavadiya on 12/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit

class CourseColorTableViewCell: UITableViewCell {

    @IBOutlet var bgImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    private func setupUI() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray
        self.selectedBackgroundView = backgroundView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
