//
//  IncreaseLineIndentAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class IncreaseLineIndentAction: NSObject, EditAction {
    
    var normalImage: UIImage {
        return #imageLiteral(resourceName: "increaselineindent-icon")
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "increaselineindent-selected-icon")
    }
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        let lineRange = (attrs.string as NSString).lineRange(for: range)
        editor.replaceCharacters(in: NSMakeRange(lineRange.location, 0), with: NSAttributedString(string:"\t"), set: NSMakeRange(range.location + 1, range.length))
    }
}
