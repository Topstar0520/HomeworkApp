//
//  TruncateSplitLineAction.swift
//  Note Editor
//
//  Created by Thang Pham on 10/9/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class TruncateSplitLineAction: NSObject, EditAction {
    
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
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        
        let lineRange = (attrs.string as NSString).lineRange(for: range)

        editor.replaceCharacters(in: NSMakeRange( NSMaxRange(range) - lineRange.length, lineRange.length), with: NSAttributedString(string: ""), set: NSMakeRange(NSMaxRange(range) - lineRange.length, 0))
    }
}
