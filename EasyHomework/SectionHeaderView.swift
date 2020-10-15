//
//  GeneralSectionHeaderView.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-01.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class SectionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var btnInfo: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        btnInfo.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    class func construct(_ title: String, owner: AnyObject) -> SectionHeaderView {
        var nibViews = Bundle.main.loadNibNamed("SectionHeaderView", owner: owner, options: nil)
        let sectionHeaderView = nibViews?[0] as! SectionHeaderView
        sectionHeaderView.titleLabel.text = title
        sectionHeaderView.contentView.backgroundColor = rgbaToUIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1.0)
        return sectionHeaderView
    }

}
