//
//  DocumentLinkView.swift
//  Note Editor
//
//  Created by Thang Pham on 8/22/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class DocumentLinkView: UIView {
    @IBOutlet weak var descImage: UIImageView!
    @IBOutlet weak var documentTitle: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    private var titleStrs: String = ""
    private var createdDateStrs: String = ""
    
    func setDocumentTitle(_ title: String) {
        self.titleStrs = title
    }
    
    func setCreatedDate(_ date: String) {
        self.createdDateStrs = date
    }
    
    func formatView() {
        self.backgroundColor = ThemeCenter.theme.editorBackgroundColor
        let documentTitleAttrs = NSMutableAttributedString(string: self.titleStrs)
        documentTitleAttrs.setAttributes([NSAttributedString.Key.font:ThemeCenter.theme.bodyFont, NSAttributedString.Key.foregroundColor: ThemeCenter.theme.bodyColor, NSAttributedString.Key.baselineOffset: 0], range: NSMakeRange(0, documentTitleAttrs.length))
        let createdDateAttrs = NSMutableAttributedString(string: self.createdDateStrs)
        createdDateAttrs.setAttributes([NSAttributedString.Key.font:ThemeCenter.theme.bodyFont, NSAttributedString.Key.foregroundColor: ThemeCenter.theme.bodyColor, NSAttributedString.Key.baselineOffset: 0], range: NSMakeRange(0, createdDateAttrs.length))
        self.documentTitle.attributedText = documentTitleAttrs
        self.createdDate.attributedText = createdDateAttrs
        let viewBorder = CAShapeLayer()
        viewBorder.strokeColor = ThemeCenter.theme.syntaxColor.cgColor
        viewBorder.frame = self.bounds
        viewBorder.fillColor = nil
        viewBorder.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5).cgPath
        self.layer.addSublayer(viewBorder)
    }
    
    class func instanceFromNib() -> DocumentLinkView {
        let documentLinkView = Bundle(identifier: EDITOR_BUNDLE_NAME)!.loadNibNamed("DocumentLinkView",
                                        owner: nil,
                                        options: nil)?.first as! DocumentLinkView
        return documentLinkView
    }
}
