//
//  UIButton+Extension.swift
//  B4Grad
//
//  Created by Sunil Zalavadiya on 05/02/19.
//  Copyright © 2019 Sunil Zalavadiya. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func makeImageLeftAligned(image: UIImage, leftMargin: CGFloat) {
        let margin = leftMargin - image.size.width / 2
        let titleRect = self.titleRect(forContentRect: self.bounds)
        let titleOffset = (bounds.width - titleRect.width - image.size.width) / 2 - margin / 2
        
        
        contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        imageEdgeInsets = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: titleOffset, bottom: 0, right: 0)
    }
    
    func centerVerticallyWithPadding(padding: CGFloat) {
        
        
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12.0, bottom: 0.0, right: 0)
        
    }
    
    func centerVerticallyWithPaddingWhileSelected(padding: CGFloat) {
        let imageSize: CGSize = (self.imageView?.frame.size)!
        
        
        var titleString: NSString = ""
        if self.titleLabel?.text?.count != 0 && self.titleLabel?.text?.count != nil {
           titleString = (self.titleLabel?.text)! as NSString
        }
        
        let titleSize: CGSize = titleString.size(withAttributes: [NSAttributedString.Key.font: (self.titleLabel?.font)!])
        
        let totalHeight: CGFloat = imageSize.height + titleSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: 0.0, bottom: 0.0, right: -titleSize.width)
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(totalHeight - titleSize.height), right: 0.0)
    }
    
    func centerVertically() {
        let kDefaultPadding: CGFloat  = 6.0;
        self.centerVerticallyWithPadding(padding: kDefaultPadding);
    }
}
