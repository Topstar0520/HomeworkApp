//
//  SyntaxStylizer.swift
//  Note Editor
//
//  Created by Pham Thang on 3/12/18.
//  Copyright © 2018 Marko Rankovic. All rights reserved.
//

import UIKit

class SyntaxStylizer: NSObject  {
    
    static func processEditing(attrs: NSMutableAttributedString, editedRange: NSRange) -> (NSRange, NSRange) {
        let originalRange = getScannedRange(attrs: attrs, changedRange: editedRange)
        let modifiedRange = SyntaxStylizer.stylizeSyntaxElements(range: originalRange, attrs: attrs, checkingStr: attrs.attributedSubstring(from: originalRange).string)
        return (originalRange, modifiedRange)
    }
    
    // extend boundary to cover all checks
    static func getScannedRange(attrs: NSMutableAttributedString, changedRange: NSRange) -> NSRange{
        
        var extendedRange = NSString(string: attrs.string).lineRange(for: changedRange)
        if NSMaxRange(extendedRange) < attrs.length {
            extendedRange = NSUnionRange(extendedRange, NSString(string: attrs.string).lineRange(for: NSMakeRange(NSMaxRange(extendedRange) + 1, 0)))
        }
        
        if extendedRange.location > 0 {
            let lineRange = NSString(string: attrs.string).lineRange(for: NSMakeRange(extendedRange.location - 1, 0))
            extendedRange = NSUnionRange(extendedRange, lineRange)
        }
        return extendedRange
    }
    
    
    
    static func stylizeSyntaxElements(range: NSRange, attrs: NSMutableAttributedString, checkingStr: String) -> NSRange {
        
        var scanningRange = range
        attrs.beginEditing()
        print(attrs)
        // add styles based on syntaxes
        
        attrs.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: ThemeCenter.theme.bodyColor, NSAttributedString.Key.backgroundColor: ThemeCenter.theme.editorBackgroundColor, NSAttributedString.Key.paragraphStyle: ThemeCenter.theme.bodyParagraphStyle,
            NSAttributedString.Key.strikethroughStyle: 0
            ], range: scanningRange)
        attrs.removeAttribute(NSAttributedString.Key.backgroundRenderingMode, range: scanningRange)
        
        print(attrs)
        if checkingStr.contains("*")  {
            scanningRange = BoldSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        if checkingStr.contains("/")  {
            scanningRange = ItalicSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        if checkingStr.contains("_")  {
            scanningRange = UnderlineSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        if checkingStr.contains("-")  {
   
            scanningRange = StrikeThroughSyntaxBuilder.instance.stylizeSyntaxElementsNew(in: scanningRange, with: attrs)
            
        }
        
        /*if checkingStr.contains("#")  {
            scanningRange = HeaderSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }*/
        
        if checkingStr.contains("-") && checkingStr.contains(">")  {
            scanningRange = ArrowSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        /*if checkingStr.contains(">")  {
            scanningRange = BlockQuoteSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }*/
        
        if checkingStr.contains("::") {
            scanningRange = HighlightSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
       /* if checkingStr.contains("---")  {
            scanningRange = DividerSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        if checkingStr.contains("*")  {
            scanningRange = BulletPointsSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        if checkingStr.contains(".")  {
            scanningRange = NumberlistSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        if  checkingStr.contains("-") || checkingStr.contains("+") {
            scanningRange = CheckBoxSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        if checkingStr.contains("#")  {
            scanningRange = HashTagSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        if checkingStr.contains("[file:") {
            scanningRange = FileAttachmentSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        if checkingStr.contains("[") && checkingStr.contains("]") {
            scanningRange = HyperlinkSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        if checkingStr.contains("[image:") {
            scanningRange = PhotoLinkSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        if checkingStr.contains("`")  {
            scanningRange = InsertCodeSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }
        
        if checkingStr.contains("```")  {
            scanningRange = MakeBlockCodeSyntaxBuilder.instance.stylizeSyntaxElements(in: scanningRange, with: attrs)
        }*/
        attrs.endEditing()
        return range
    }
    
    static func checkLastCharacter(in range: NSRange, with attrs: NSMutableAttributedString) -> NSRange{
        var scanningRange = range
        attrs.append(NSAttributedString(attachment: NSTextAttachment()))
        scanningRange.length += 1
        return scanningRange
    }
    
    static func removeAttachments(in range: NSRange, attrs: NSMutableAttributedString) -> NSRange {
        if attrs.containsAttachments(in: range) {
            var indexes = [Int]()
            attrs.enumerateAttribute(NSAttributedString.Key.attachment, in: range, options: .longestEffectiveRangeNotRequired) { (value, matchRange, stop) in
                if let _ = value as? NSTextAttachment {
                    indexes.append(matchRange.location)
                }
            }
            var shiftLen = 0
            for i in 0..<indexes.count {
                attrs.deleteCharacters(in: NSMakeRange(indexes[i] - shiftLen, 1))
                shiftLen += 1
            }
            return NSMakeRange(range.location, range.length - shiftLen)
        }
        return range
    }
    
    static func removeTabs(in range: NSRange, attrs: NSMutableAttributedString) -> NSRange {
        var indexes = [Int]()
        (attrs.string as NSString).enumerateSubstrings(in: range, options: .byComposedCharacterSequences) { (subString, subStringRange, enclosingRange, stop) in
            if subString == "\t" {
                indexes.append(subStringRange.location)
            }
        }
        var shiftLen = 0
        for i in 0..<indexes.count {
            attrs.deleteCharacters(in: NSMakeRange(indexes[i] - shiftLen, 1))
            shiftLen += 1
        }
        return NSMakeRange(range.location, range.length - shiftLen)
    }
    
}
