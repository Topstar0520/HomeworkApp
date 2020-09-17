//
//  NoteExporter.swift
//  Note Editor
//
//  Created by Thang Pham on 8/28/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

enum ExportFileType: String {
    case txt = "txt"
    case rtf = "rtf"
}

class NoteExporter {
    static let sharedInstance = NoteExporter()
    var fileFormatters = [ExportFileType: FileFormatter]()
    
    init() {
        fileFormatters[.txt] = TxtFileFormatter()
        fileFormatters[.rtf] = RTFFileFormatter()
    }
    
    func export(attrs: NSAttributedString,to fileType: ExportFileType) -> URL? {
        guard let fileFormatter = fileFormatters[fileType] else { return nil}
        return fileFormatter.format(attrs: attrs)
    }
}
