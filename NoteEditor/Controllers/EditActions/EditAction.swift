//
//  EditAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

enum CursorMoveDirection {
    case Up
    case Down
    case Left
    case Right
}

enum TextHeaderType: Int{
    case H1 = 1
    case H2 
    case H3
    case Other
    case NoHeader
}

protocol EditAction: NSObjectProtocol {
    var normalImage: UIImage {get}
    var selectedImage: UIImage {get}
    var editor: NoteEditor! {get set}
    init (editor: NoteEditor)
    func execute(in range: NSRange, with attrs: NSAttributedString,textview:UITextView)
}

