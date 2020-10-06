//
//  TutorialsTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-08-26.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit

class TutorialsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lhsLabel: UILabel!

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
