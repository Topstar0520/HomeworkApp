//
//  MakeHeaderAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class MakeHeaderAction: NSObject, EditAction {
    
    var normalImage: UIImage = UIImage(named: "makeheader-icon", in: bundle, compatibleWith: nil)!
    
    var selectedImage: UIImage = UIImage(named: "makeheader-selected-icon", in: bundle, compatibleWith: nil)!
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        editor.requestHeaderType { (headerType) in
            let headerLen = headerType.rawValue + 2
            self.editor.textView.undoManager?.beginUndoGrouping()
            if let (replacingRange, replacingString) = MarkupSyntaxTruncater.instance.truncateHeaders(in: range, with: attrs) {
                self.editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(range.location - headerLen, range.length))
                let (replaceRange, replaceString) = HeaderSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: headerType)
                self.editor.replaceCharacters(in: replaceRange, with: replaceString, set: NSMakeRange(self.editor.textView.selectedRange.location + headerLen, range.length))
            }else {
                let (replacingRange, replacingString) = HeaderSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: headerType)
                self.editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(range.location + headerLen, range.length))
            }
            self.editor.textView.undoManager?.endUndoGrouping()
        }
    }
}
