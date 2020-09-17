//
//  InsertPhotoAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class InsertPhotoAction: NSObject, EditAction {

    var normalImage: UIImage {
        return #imageLiteral(resourceName: "insertphoto-icon")
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "insertphoto-selected-icon")
    }
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        editor.requestPhoto(completion: { (imageName) in
            if let name = imageName {
                let (replacingRange, replacingString) = PhotoLinkSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: name)
                self.editor.replaceCharacters(in: replacingRange, with: replacingString, set: replacingRange)
            }
        })
    }
}
