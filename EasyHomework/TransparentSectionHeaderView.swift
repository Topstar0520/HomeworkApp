//
//  TransparentSectionHeaderView.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-12-19.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class TransparentSectionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    class func construct(_ title: String, owner: AnyObject) -> TransparentSectionHeaderView {
        var nibViews = Bundle.main.loadNibNamed("TransparentSectionHeaderView", owner: owner, options: nil)
        let sectionHeaderView = nibViews?[0] as! TransparentSectionHeaderView
        sectionHeaderView.titleLabel.text = title
        sectionHeaderView.contentView.backgroundColor = UIColor.clear
        return sectionHeaderView
    }

}
