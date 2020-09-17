//
//  InsertHyperlinkAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class InsertHyperlinkAction: NSObject, EditAction {

    var normalImage: UIImage {
        return #imageLiteral(resourceName: "inserthyperlink-icon")
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "inserthyperlink-selected-icon")
    }
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        requestHyperlink(in:range, with: attrs, preemptedTitle: (attrs.string as NSString).substring(with: range), preemptedLink: "")
    }
    
    func requestHyperlink(in range: NSRange, with attrs: NSAttributedString, preemptedTitle: String, preemptedLink: String) {
        editor.requestHyperlink(preemptedTitle: preemptedTitle, preemptedLink: preemptedLink, completion: { (title, hyperlink) in
            if let name = title, let link = hyperlink  {
                let (replacingRange, replacingString) = HyperlinkSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: Hyperlink(title: name, url: link))
                self.editor.replaceCharacters(in: replacingRange, with: replacingString, set: replacingRange)
            }
        })
    }
}
