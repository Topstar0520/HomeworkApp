//
//  NoteTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-04-16.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell { //in cellEditingVC
    
    @IBOutlet weak var circleView: CircleView!
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var imgVew: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
