//
//  HeaderView.swift
//  Note Editor
//
//  Created by Thang Pham on 8/22/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    
    @IBOutlet weak var subscriptNumber: UILabel!
    @IBOutlet weak var title: UILabel!
    
    private var number: Int = 0
    
    func setSubsript(_ number: Int) {
        self.number = number
    }
    
    func formatView() {
        self.backgroundColor = ThemeCenter.theme.editorBackgroundColor
        let titleAttrs = NSMutableAttributedString(string: "H")
        titleAttrs.setAttributes([NSAttributedString.Key.font:ThemeCenter.theme.bodyFont, NSAttributedString.Key.foregroundColor: ThemeCenter.theme.syntaxColor, NSAttributedString.Key.baselineOffset: 0], range: NSMakeRange(0, titleAttrs.length))
        let subscriptAttrs = NSMutableAttributedString(string: "\(number)")
        subscriptAttrs.setAttributes([NSAttributedString.Key.font:ThemeCenter.theme.subscriptFont, NSAttributedString.Key.foregroundColor: ThemeCenter.theme.syntaxColor, NSAttributedString.Key.baselineOffset: 0], range: NSMakeRange(0, subscriptAttrs.length))
        self.title.attributedText = titleAttrs
        self.subscriptNumber.attributedText = subscriptAttrs
    }
    
    class func instanceFromNib() -> HeaderView {
        let headerView =  Bundle(identifier: EDITOR_BUNDLE_NAME)!.loadNibNamed("HeaderView",
                                 owner: nil,
                                 options: nil)?.first as! HeaderView
        return headerView
    }
}
