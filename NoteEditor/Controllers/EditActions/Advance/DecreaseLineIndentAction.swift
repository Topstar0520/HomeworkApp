//
//  DecreaseLineIndentAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class DecreaseLineIndentAction: NSObject, EditAction {
    
    var normalImage: UIImage {
        return #imageLiteral(resourceName: "decreaselineindent-icon")
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "decreaselineindent-icon")
    }
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }

    func execute(in range: NSRange, with attrs: NSAttributedString) {
        let lineRange = (attrs.string as NSString).lineRange(for: range)
        if let firstCharacter = (attrs.string as NSString).substring(with: lineRange).first {
            if firstCharacter == "\t" {
                    editor.replaceCharacters(in: NSMakeRange(lineRange.location, 1), with: NSAttributedString(string: ""), set: NSMakeRange(range.location - 1, range.length))
            }
        }
    }
}
