//
//  MarkupSyntaxTruncater.instance.swift
//  Note Editor
//
//  Created by Thang Pham on 8/30/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

class MarkupSyntaxTruncater {
    
    static let instance = MarkupSyntaxTruncater()
    
    func truncateHeaders(in range: NSRange, with string: NSAttributedString) -> (NSRange, NSAttributedString)? {
        /*if let (replacingRange, replacingString) = HeaderSyntaxBuilder.instance.truncateMarkupSyntax(in: range, with: string) { return (replacingRange, replacingString) }
        if let (replacingRange, replacingString) = BulletPointsSyntaxBuilder.instance.truncateMarkupSyntax(in: range, with: string) { return (replacingRange, replacingString) }
        if let (replacingRange, replacingString) = NumberlistSyntaxBuilder.instance.truncateMarkupSyntax(in: range, with: string) { return (replacingRange, replacingString) }
        if let (replacingRange, replacingString) = BlockQuoteSyntaxBuilder.instance.truncateMarkupSyntax(in: range, with: string) { return (replacingRange, replacingString) }
        if let (replacingRange, replacingString) = CheckBoxSyntaxBuilder.instance.truncateMarkupSyntax(in: range, with: string) { return (replacingRange, replacingString) }*/
        return nil
    }
    
    func truncateImages(in range: NSRange, with string: NSAttributedString) -> (NSRange, NSAttributedString)? {
        return nil
        //return PhotoLinkSyntaxBuilder.instance.truncateMarkupSyntax(in: range, with: string)
    }
    
    func isHeader(in range: NSRange, with string: NSAttributedString) -> Bool {
        return false
        /*return HeaderSyntaxBuilder.instance.isHeaderSyntax(in:range, with:string) ||
        BulletPointsSyntaxBuilder.instance.isBulletPointsSyntax(in:range, with:string) ||
        NumberlistSyntaxBuilder.instance.isNumberlistSyntax(in:range, with:string) ||
        BlockQuoteSyntaxBuilder.instance.isBlockQuoteSyntax(in:range, with:string) ||
        CheckBoxSyntaxBuilder.instance.isCheckBoxSyntax(in:range, with:string)*/
    }
}
