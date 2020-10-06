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
        let selectedBackgroundView = UIView()   //added by @solysky20200929
        selectedBackgroundView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12)  //added by @solysky20200929
        self.selectedBackgroundView = selectedBackgroundView    //added by @solysky20200929
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
