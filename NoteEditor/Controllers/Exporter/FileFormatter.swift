//
//  FileFormatter.swift
//  Note Editor
//
//  Created by Thang Pham on 8/28/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

protocol FileFormatter {
    func format(attrs: NSAttributedString) -> URL?
}

class TxtFileFormatter: FileFormatter {
    func format(attrs: NSAttributedString) -> URL? {
        do {
            let mutableAttrs = NSMutableAttributedString(attributedString: attrs)
            let scanningRange = SyntaxStylizer.removeAttachments(in: NSMakeRange(0, mutableAttrs.length), attrs: mutableAttrs)
            _ = SyntaxStylizer.removeTabs(in: scanningRange, attrs: mutableAttrs)
            if let data =  mutableAttrs.string.data(using: .unicode) {
                if let assetFolderURL = NEFileManager.assetFolderURL() {
                    let path = assetFolderURL.appendingPathComponent("exportfile").appendingPathExtension("txt")
                    try data.write(to: path)
                    return path
                }
            }
        }catch (let error) {
            print(error)
        }
        return nil
    }
}

class RTFFileFormatter: FileFormatter {
    func format(attrs: NSAttributedString) -> URL? {
        do {
            ThemeCenter.setTheme(type: .RTFExport)
            let mutableAttrs = NSMutableAttributedString(attributedString: attrs)
            let scanningRange = SyntaxStylizer.stylizeSyntaxElements(range: NSMakeRange(0, mutableAttrs.length), attrs: mutableAttrs, checkingStr: mutableAttrs.string)
            _ = SyntaxStylizer.removeTabs(in: scanningRange, attrs: mutableAttrs)
            ThemeCenter.setTheme(type: .Default)
            let data = try mutableAttrs.data(from: NSMakeRange(0, mutableAttrs.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType : NSAttributedString.DocumentType.rtf])
            if let assetFolderURL = NEFileManager.assetFolderURL() {
                let path = assetFolderURL.appendingPathComponent("exportfile").appendingPathExtension("rtf")
                try data.write(to: path)
                return path
            }
        }catch (let error) {
            print(error)
        }
        return nil
    }
}
