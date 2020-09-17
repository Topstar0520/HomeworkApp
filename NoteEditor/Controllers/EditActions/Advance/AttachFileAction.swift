//
//  AttachFileAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class AttachFileAction: NSObject, EditAction {
    
    private var url: URL!
    
    var normalImage: UIImage {
        return #imageLiteral(resourceName: "attachfile-icon")
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "attachfile-selected-icon")
    }
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        editor.requestFileAttachment(completion: { (fileName) in
            if let name = fileName {
                let (replacingRange, replacingString) = FileAttachmentSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: name)
                self.editor.replaceCharacters(in: replacingRange, with: replacingString, set: replacingRange)
            }
        })
    }
}
