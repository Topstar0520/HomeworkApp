//
//  EditHyperlinkAction.swift
//  Note Editor
//
//  Created by Thang Pham on 9/12/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

class EditHyperlinkAction: InsertHyperlinkAction {
    
    override func execute(in range: NSRange, with attrs: NSAttributedString) {
        if let (editRange, title, link) = HyperlinkSyntaxBuilder.instance.analyze(in: range, with: attrs) {
            requestHyperlink(in:editRange, with: attrs, preemptedTitle: title, preemptedLink: link)
        }
        
    }
}
