//
//  NoteFile.swift
//  Note Editor
//
//  Created by Thang Pham on 8/15/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class NoteFile: UIDocument {
    private var noteId: String!
    private let name = "note"
    var attrs: NSMutableAttributedString!
    
    init(noteDescriptor: NoteDescriptor) {
        self.noteId = noteDescriptor.id
        let url = NEFileManager.noteFromAssetFolder(id: noteId)?.appendingPathComponent(name)
        super.init(fileURL: url!)
    }
    
    // MARK: I/O Operations
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let fileWrapper = contents as? FileWrapper {
            if let textFileWrapper = fileWrapper.fileWrappers![name] {
                if let data = textFileWrapper.regularFileContents {
                    self.attrs = NSMutableAttributedString(string: String(data: data, encoding: .unicode)!)
                }
            }
        }
    }
    
    override func contents(forType typeName: String) throws -> Any {
        let contentsFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
        if let data = self.attrs.string.data(using: .unicode) {
            let textFileWrapper = FileWrapper(regularFileWithContents: data)
            textFileWrapper.preferredFilename = name
            contentsFileWrapper.addFileWrapper(textFileWrapper)
        }
        return contentsFileWrapper
    }
    
    // MARK: Note statistics
    
    func countWords() -> Int {
        var count = 0

        attrs.string.enumerateSubstrings(in: attrs.string.startIndex..<attrs.string.endIndex, options: .byWords) { (_, _, _, _) in
            count += 1
        }
        return count
    }
    
    func countCharacters() -> Int {
        return attrs.length
    }
    
    func countParagraphs() -> Int {
        var count = 0
        attrs.string.enumerateSubstrings(in: attrs.string.startIndex..<attrs.string.endIndex, options: .byParagraphs) { (matchString, _, _, _) in
            if let str = matchString {
                if !str.isEmpty {
                    count += 1
                }
            }
        }
        return count
    }
    
    func getModifiedDate() -> NSDate? {
        if let textFilePath = NEFileManager.getFileURLFromAssetFolder(noteId: noteId, file: name)?.path {
            return NEFileManager.modifiedDateOfFile(path: textFilePath)
        }
        return nil
    }
    
    func getCreatedDate() -> NSDate? {
        if let textFilePath = NEFileManager.getFileURLFromAssetFolder(noteId: noteId, file: name)?.path {
            return NEFileManager.createdDateOfFile(path: textFilePath)
        }
        return nil
    }
}
