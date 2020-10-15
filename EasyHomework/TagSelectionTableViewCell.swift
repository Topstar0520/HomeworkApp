//
//  TagSelectionTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-27.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class TagSelectionTableViewCell: UITableViewCell {

    @IBOutlet var collectionView: UICollectionView!
    //@IBOutlet var heightConstraintOfCollectionView: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.allowsMultipleSelection = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
