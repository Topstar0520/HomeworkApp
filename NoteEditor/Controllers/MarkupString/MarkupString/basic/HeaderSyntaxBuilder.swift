//
//  HeaderSyntaxBuilder.instance.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class HeaderSyntaxBuilder: MarkupSyntaxBuilder {

    static let instance = HeaderSyntaxBuilder()
    
    func regex() -> NSRegularExpression {
        let pattern = "(?:\\n|\\r|^|\\G)(#+)(.{0,1})(?:\\h+?)(\\t*)(.*)(?:\\r|\\n|$)"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        return reg
    }
    
    func stylizeSyntaxElements(in range:NSRange, with string: NSMutableAttributedString) -> NSRange {
        var insertMarks = [InsertionMark]()
        regex().enumerateMatches(in: string.string , options: [], range: range, using: { (match, flags, stop) in
            if let hashRange = match?.range(at: 1), let attachmentRange = match?.range(at:2), let tabRange = match?.range(at:3), let headerRange = match?.range(at: 4){

                string.addAttributes([NSAttributedString.Key.font : ThemeCenter.theme.emptyFont
                    ], range: hashRange)
                
                string.addAttributes([NSAttributedString.Key.paragraphStyle: ThemeCenter.theme.headerParagraphStyle
                    ], range: NSMakeRange(hashRange.location, NSMaxRange(headerRange) - hashRange.location))
                
                let headerType = hashRange.length <= 3 ? TextHeaderType(rawValue: hashRange.length)! : TextHeaderType.Other
                
                string.addAttributes([NSAttributedString.Key.font : ThemeCenter.theme.headerFont(type: headerType)], range: NSMakeRange(NSMaxRange(hashRange), NSMaxRange(headerRange) - NSMaxRange(hashRange)))
                
                if attachmentRange.length == 0 || string.attribute(NSAttributedString.Key.link, at: attachmentRange.location, effectiveRange: nil) == nil {
                    let textAttachment = NSTextAttachment()
                    let headerView = HeaderView.instanceFromNib()
                    headerView.setSubsript(hashRange.length)
                    headerView.formatView()
                    textAttachment.image = UIImage.getImageFromView(headerView)!
                    let attrs = NSAttributedString(attachment: textAttachment)
                    
                    if AttachmentLinkBuilder.instance.noteDescriptor != nil {
                        if attachmentRange.length == 0  {
                            let mutableAttrs = NSMutableAttributedString(attributedString: attrs)
                            mutableAttrs.addAttribute(NSAttributedString.Key.link, value:  URL(string: "NoteEditor://x-callback-url/header")!, range: NSMakeRange(0, attrs.length))
                            mutableAttrs.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.bodyColor, NSAttributedString.Key.paragraphStyle: ThemeCenter.theme.headerParagraphStyle, NSAttributedString.Key.font : ThemeCenter.theme.headerFont(type: headerType)], range: NSMakeRange(0, mutableAttrs.length))
                            insertMarks.append(InsertionMark(attr: mutableAttrs, location: NSMaxRange(hashRange)))
                        }else {
                            string.addAttribute(.attachment, value: textAttachment, range: attachmentRange)
                            string.addAttribute(NSAttributedString.Key.link, value:  URL(string: "NoteEditor://x-callback-url/header")!, range: attachmentRange)
                        }
                        
                        if tabRange.length == 0 && headerRange.length != 0 {
                            let attrs = NSMutableAttributedString(string: "\t")
                            attrs.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.bodyColor, NSAttributedString.Key.paragraphStyle: ThemeCenter.theme.headerParagraphStyle, NSAttributedString.Key.font : ThemeCenter.theme.headerFont(type: headerType)], range: NSMakeRange(0, attrs.length))
                            insertMarks.append(InsertionMark(attr: attrs, location: tabRange.location))
                         }
                    }
                }
            }
        })
        var shiftLen = 0
        for insertMark in insertMarks {
            string.insert(insertMark.attr, at: insertMark.location + shiftLen)
            shiftLen += insertMark.attr.length
        }
        return NSMakeRange(range.location, range.length + shiftLen)
    }
    
    func isHeaderSyntax(in range: NSRange, with string: NSAttributedString) -> Bool {
        let pattern = "(#+.\\h+?\\t*)"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        if reg.rangeOfFirstMatch(in: string.string, options: [], range: range) == range {
            return true
        }
        return false
    }
    
    func isContainingSyntax(in range: NSRange, with string: NSAttributedString) -> (Bool, NSAttributedString) {
        let pattern = "(?:\\n|\\r|^|\\G)(#+.\\h+?\\t*)(.*)(?:\\r|\\n|$)"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        if let firstMatch = reg.firstMatch(in: string.string, options: [], range: range) {
            let tag = string.attributedSubstring(from: firstMatch.range(at: 1))
            return (true, tag)
        }
        return (false, NSAttributedString(string:""))
    }
    
    func truncateMarkupSyntax(in range: NSRange, with string: NSAttributedString) -> (NSRange, NSAttributedString)? {
        let pattern = "(?:\\n|\\r|^|\\G)(#+.\\h+?\\t*)(.*)(?:\\r|\\n|$)"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        let paragraphRange = (string.string as NSString).paragraphRange(for: range)
        let str = NSMutableAttributedString()
        var isCharactersDeleted = false
        (string.string as NSString).enumerateSubstrings(in: paragraphRange, options: .byLines) { (_, _,enclosingRange, _) in
            let lineString = NSMutableAttributedString(attributedString: string.attributedSubstring(from: enclosingRange))
            var removeRanges = [NSRange]()
            reg.enumerateMatches(in: lineString.string, options: [], range: NSMakeRange(0, lineString.length), using: { (match, flags, stop) in
                if let startTagRange = match?.range(at: 1) {
                    removeRanges.append(startTagRange)
                }
            })
            var shiftLen = Int(0)
            for removeRange in removeRanges {
                lineString.deleteCharacters(in: NSMakeRange(removeRange.location - shiftLen, removeRange.length))
                shiftLen += removeRange.length
                isCharactersDeleted = true
            }
            str.append(lineString)
        }
        return isCharactersDeleted ? (paragraphRange, str as NSAttributedString) : nil
    }
    
    func addMarkupSyntax(in range: NSRange, with string: NSAttributedString, optional value: Any?) -> (NSRange, NSAttributedString) {
        if let v = value as? TextHeaderType {
            var prefix = String()
            switch v {
            case .H1:
                prefix = "# "
            case .H2:
                prefix = "## "
            case .H3:
                prefix = "### "
            default:
                prefix = String()
            }
            
            let paragraphRange = (string.string as NSString).paragraphRange(for: range)
            let str = NSMutableAttributedString(attributedString: string.attributedSubstring(from: paragraphRange))
            let attrPrefix = NSMutableAttributedString(string: prefix)
            var insertPoints = [Int]()
            (str.string as NSString).enumerateSubstrings(in: NSMakeRange(0, str.length), options: .byLines) { (_, matchRange,_, _) in
                if matchRange.length > 0 {
                    insertPoints.append(matchRange.location)
                }
            }
            var shiftLen = Int(0)
            if insertPoints.isEmpty {
                str.insert(attrPrefix, at: 0)
            }else {
                for point in insertPoints {
                    str.insert(attrPrefix, at: point + shiftLen)
                    shiftLen += attrPrefix.length
                }
            }
            return (paragraphRange, str)
        }
        return (range, string)
    }
}
