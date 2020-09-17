//
//  PhotoLinkSyntaxBuilder.instance.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class PhotoLinkSyntaxBuilder: MarkupSyntaxBuilder {
    
    static let instance = PhotoLinkSyntaxBuilder()
    
    func regex() -> NSRegularExpression {
        let pattern = "(\\[image:)(.*)(])(.{0,1})"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        return reg
    }
    
    func stylizeSyntaxElements(in range:NSRange, with string: NSMutableAttributedString) -> NSRange {
        var insertMarks = [InsertionMark]()
        regex().enumerateMatches(in: string.string , options: [], range: range, using: { (match, flags, stop) in
            
            if let startTagRange = match?.range(at: 1), let fileNameRange = match?.range(at: 2), let endTagRange = match?.range(at: 3), let linkTag = match?.range(at: 4) {
                string.addAttribute(NSAttributedString.Key.font, value: ThemeCenter.theme.emptyFont, range: NSMakeRange(startTagRange.location, startTagRange.length + fileNameRange.length + endTagRange.length))
                let textAttachment = NSTextAttachment()
                let filename = (string.string as NSString).substring(with: fileNameRange)
                if linkTag.length == 0 ||  string.attribute(.link, at: linkTag.location, effectiveRange: nil) == nil {
                    if let url = AttachmentLinkBuilder.instance.url(for: filename) {
                        textAttachment.image = UIImage(contentsOfFile: url.path)
                        let attrs = NSAttributedString(attachment: textAttachment)
                        let mutableAttrs = NSMutableAttributedString(attributedString: attrs)
                        mutableAttrs.addAttribute(NSAttributedString.Key.link, value: url, range: NSMakeRange(0, attrs.length))
                        insertMarks.append(InsertionMark(attr: mutableAttrs, location: NSMaxRange(endTagRange)))
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
    
    func isContainingSyntax(in range: NSRange, with string: NSAttributedString) -> (Bool, String) {
        let pattern = "(\\[image:.*])"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        var tag = String()
        reg.enumerateMatches(in: string.string, options: [], range: range) { (match, flags, stop) in
            if let tagRange = match?.range(at: 1) {
                if NSMaxRange(range) == NSMaxRange(tagRange) {
                    tag = (string.string as NSString).substring(with: tagRange)
                }
            }
        }
        return tag.isEmpty ? (false, "") : (true, tag)
    }
    
    func truncateMarkupSyntax(in range: NSRange, with string: NSAttributedString) -> (NSRange, NSAttributedString)? {
        let pattern = "(\\[image:.*]\\n*)"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        let str = NSMutableAttributedString(attributedString: string.attributedSubstring(from: range))
        var isCharactersDeleted = false
        var removeRanges = [NSRange]()
        reg.enumerateMatches(in: string.string , options: [], range: range, using: { (match, flags, stop) in
            if let matchRange = match?.range(at: 1) {
                removeRanges.append(matchRange)
            }
        })
        var shiftLen = Int(0)
        for removeRange in removeRanges {
            str.deleteCharacters(in: NSMakeRange(removeRange.location - shiftLen, removeRange.length))
            shiftLen += removeRange.length
            isCharactersDeleted = true
        }
        return isCharactersDeleted ? (range, str as NSAttributedString) : nil
    }
    
    func addMarkupSyntax(in range: NSRange, with string: NSAttributedString, optional value: Any?) -> (NSRange, NSAttributedString) {
        if let v = value as? String {
            return (range, NSAttributedString(string:"[image:\(v)]"))
        }
        return (range, string)
    }
}
