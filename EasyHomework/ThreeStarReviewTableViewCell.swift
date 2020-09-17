//
//  ThreeStarReviewTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-26.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class ThreeStarReviewTableViewCell: UITableViewCell {
    
    @IBOutlet var tag1View: TagView!
    @IBOutlet var tag2View: TagView!
    @IBOutlet var tag3View: TagView!
    @IBOutlet var tag1ImageView: UIImageView!
    @IBOutlet var tag1Label: UILabel!
    @IBOutlet var tag2ImageView: UIImageView!
    @IBOutlet var tag2Label: UILabel!
    @IBOutlet var tag3ImageView: UIImageView!
    @IBOutlet var tag3Label: UILabel!
    @IBOutlet var emojiLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
