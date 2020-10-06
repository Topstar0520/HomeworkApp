//
//  EmptyHomescreenView.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-04-13.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class EmptyHomescreenView: UIView {
    
    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet var mainTitleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var arrowImageView: UIImageView!
    @IBOutlet var mainImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame = ScreenSize.SCREEN_BOUNDS
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.visualEffectView.layer.cornerRadius = self.visualEffectView.frame.size.width / 9
        self.visualEffectView.layer.masksToBounds = true
    }
    
    class func construct(_ owner : AnyObject, title : String, description : String) -> EmptyHomescreenView {
        var nibViews = Bundle.main.loadNibNamed("EmptyHomescreenView", owner: owner, options: nil)
        let emptyHomescreenView = nibViews?[0] as! EmptyHomescreenView
        emptyHomescreenView.mainTitleLabel.text = title
        emptyHomescreenView.descriptionLabel.text = description
        return emptyHomescreenView
    }

}
