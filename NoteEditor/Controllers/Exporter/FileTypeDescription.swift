//
//  FileTypeDescription.swift
//  Note Editor
//
//  Created by Thang Pham on 9/7/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

protocol FileTypeDescription {
    var type: ExportFileType {get}
    var name: String {get}
    var description: String {get}
}

class TXTFileDescription: FileTypeDescription {
    
    var type: ExportFileType {
        get {
            return .txt
        }
    }
    
    var name: String {
        get {
            return "Text File Format"
        }
    }
    
    var description: String {
        get {
            return "A very basic file format for use in applications such as notepad"
        }
    }
}

class RTFFileDescription: FileTypeDescription {
    
    var type: ExportFileType {
        get {
            return .rtf
        }
    }
    
    var name: String {
        get {
            return "Rich Text File Format"
        }
    }
    
    var description: String {
        get {
            return "A text file format used by Microsoft products such as Word and Office"
        }
    }
}
