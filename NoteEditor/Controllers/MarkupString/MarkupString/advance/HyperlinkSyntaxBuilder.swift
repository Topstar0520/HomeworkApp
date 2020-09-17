//
//  MarkupSyntaxBuilder.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

struct Hyperlink {
    var title: String
    var url: String
}

class HyperlinkSyntaxBuilder: MarkupSyntaxBuilder {

    static let instance = HyperlinkSyntaxBuilder()
    
    func regex() -> NSRegularExpression {
        let pattern = "(\\[)(.*?)(])(\\()(.*?)(\\))"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        return reg
    }
    
    func stylizeSyntaxElements(in range:NSRange, with string: NSMutableAttributedString) -> NSRange {
        var insertMarks = [InsertionMark]()
        regex().enumerateMatches(in: string.string , options: [], range: range, using: { (match, flags, stop) in
            if let startRoundTag = match?.range(at: 1), let titleRange = match?.range(at: 2),let endRoundTag = match?.range(at: 3),let startSquareTag = match?.range(at: 4),let linkRange = match?.range(at: 5),let endSquareTag = match?.range(at: 6){
                string.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.syntaxColor], range: startRoundTag)
                string.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.syntaxColor], range: endRoundTag)
                string.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.syntaxColor], range: startSquareTag)
                string.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.syntaxColor], range: endSquareTag)
                
                string.addAttributes([NSAttributedString.Key.font : ThemeCenter.theme.emptyFont], range: linkRange)
                
                if AttachmentLinkBuilder.instance.noteDescriptor != nil && string.attribute(.link, at: titleRange.location, effectiveRange: nil) == nil{
                    var url: URL? = nil
                    if string.attribute(.link, at: titleRange.location, effectiveRange: nil) == nil {
                        url = URL(string: string.attributedSubstring(from: linkRange).string)
                    }else {
                        url = URL(string: string.attributedSubstring(from: NSMakeRange(linkRange.location, linkRange.length - 1)).string)
                    }
                    if let linkURL = url {
                        string.addAttributes([NSAttributedString.Key.link: linkURL], range: titleRange)
                    }
                }
                string.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.linkColor], range: titleRange)
                if string.attribute(.link, at: endSquareTag.location - 1, effectiveRange: nil) == nil{
                    let textAttachment = NSTextAttachment()
                    textAttachment.image = #imageLiteral(resourceName: "inserthyperlink-icon")
                    textAttachment.bounds = CGRect(x: 0, y: 0, width: ThemeCenter.theme.bodyFont.lineHeight*10.0/12.0, height: ThemeCenter.theme.bodyFont.lineHeight*5.0/8.0)
                    
                    let attrs = NSAttributedString(attachment: textAttachment)
                    let mutableAttrs = NSMutableAttributedString(attributedString: attrs)
                    mutableAttrs.addAttribute(NSAttributedString.Key.link, value:  URL(string: "NoteEditor://x-callback-url/hyperlink")!, range: NSMakeRange(0, mutableAttrs.length))
                    string.addAttribute(NSAttributedString.Key.link, value:  URL(string: "NoteEditor://x-callback-url/hyperlink")!, range: linkRange)
                    let insertRange = NSMakeRange(endSquareTag.location, 1)
                    insertMarks.append(InsertionMark(attr: mutableAttrs, location: insertRange.location))
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
    
    func truncateMarkupSyntax(in range: NSRange, with string: NSAttributedString) -> (NSRange, NSAttributedString)? {
        return nil
    }
    
    func addMarkupSyntax(in range: NSRange, with string: NSAttributedString, optional value: Any?) -> (NSRange, NSAttributedString) {
        if let v = value as? Hyperlink {
            return (range, NSAttributedString(string:"[\(v.title)](\(v.url))"))
        }
        return (range, string)
    }
    
    func analyze(in range: NSRange, with string: NSAttributedString) -> (NSRange, String, String)? {
        let pattern = "(\\[)(.*?)(])(\\()(.*?)(\\))"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        let lineRange = (string.string as NSString).lineRange(for: range)
        var title = ""
        var link = ""
        var enclosingRange = NSRange()
        var matched = false
        reg.enumerateMatches(in: string.string , options: [], range: lineRange, using: { (match, flags, stop) in
            
            if let startTag = match?.range(at: 1), let titleRange = match?.range(at: 2),let linkRange = match?.range(at: 5), let endTag = match?.range(at: 6){
                title = (string.string as NSString).substring(with: titleRange)
                link = (string.string as NSString).substring(with: linkRange)
                enclosingRange = NSMakeRange(startTag.location, NSMaxRange(endTag) - startTag.location)
                matched = true
            }
        })
        return matched ? (enclosingRange, title, link) : nil
    }
}
