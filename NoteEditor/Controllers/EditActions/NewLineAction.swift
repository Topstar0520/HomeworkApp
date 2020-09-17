//
//  NewLineAction.swift
//  Note Editor
//
//  Created by Thang Pham on 9/8/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class NewLineAction: NSObject, EditAction {
    
    var normalImage: UIImage {
        get {
            return UIImage()
        }
    }
    
    var selectedImage: UIImage {
        get {
            return UIImage()
        }
    }
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString,textview:UITextView) {
        
        let lineRange = (attrs.string as NSString).lineRange(for: range)

        /*var (valid, tag) = BulletPointsSyntaxBuilder.instance.isContainingSyntax(in: lineRange, with: attrs)
        if (valid == false) {
            (valid, tag) = BlockQuoteSyntaxBuilder.instance.isContainingSyntax(in: lineRange, with: attrs)
        }
        if (valid == false) {
            (valid, tag) = CheckBoxSyntaxBuilder.instance.isContainingSyntax(in: lineRange, with: attrs)
        }
        if (valid == false) {
            (valid, tag) = NumberlistSyntaxBuilder.instance.isContainingSyntax(in: lineRange, with: attrs)
            if valid {
                let pattern = "(\\d+)\\.\\h+?\\t*"
                let reg = try! NSRegularExpression(pattern: pattern, options: [])
                if let firstMatch = reg.firstMatch(in: tag.string, options: [], range: NSMakeRange(0, tag.length)) {
                    let number = (tag.string as NSString).substring(with: firstMatch.range(at: 1))
                    let idx = Int(number)! + 1
                    let replaceAttrs = NSMutableAttributedString(string:"\(idx). \t")
                    replaceAttrs.setAttributes(tag.attributes(at: 0, effectiveRange: nil), range: NSMakeRange(0, replaceAttrs.length))
                    tag = replaceAttrs
                }
            }
        }

        if (tag.length == 0) {
            (valid, tag) = HeaderSyntaxBuilder.instance.isContainingSyntax(in: lineRange, with: attrs)
            if valid {
                tag = NSAttributedString(string: "\t")
            }
        }*/
        editor.replaceCharacters(in: range, with: NSAttributedString(string: "\n"), set: NSMakeRange(range.location + 1, 0))
        //editor.replaceCharacters(in: range, with: NSAttributedString(string: "\n" + tag.string), set: NSMakeRange(range.location + tag.length + 1, 0))
    }
}
