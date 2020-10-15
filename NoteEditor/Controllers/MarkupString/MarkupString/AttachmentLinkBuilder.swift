//
//  AttachmentLinkBuilder.instance.swift
//  Note Editor
//
//  Created by Thang Pham on 9/9/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

class AttachmentLinkBuilder {
    
    static let instance = AttachmentLinkBuilder()
    
    var noteDescriptor: NoteDescriptor?
    
    func url(for name: String) -> URL? {
        if let descriptor = noteDescriptor {
            return NEFileManager.getFileURLFromAssetFolder(noteId: descriptor.id, file: name)
        }
        return nil
    }
}
