//
//  DefaultTheme.swift
//  Note Editor
//
//  Created by Thang Pham on 8/18/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class RTFExportTheme: Theme {
    
    var editorBackgroundColor: UIColor {
        get {
            return RTFExportTheme.BackgroundColor
        }
    }
    
    var bodyParagraphStyle: NSParagraphStyle {
        get {
            return RTFExportTheme.BodyParagraphStyle
        }
    }
    
    var headerParagraphStyle: NSParagraphStyle {
        get {
            return RTFExportTheme.HeaderParagraphStyle
        }
    }
    
    var bulletAndListParagraphStyle: NSParagraphStyle {
        get {
            return RTFExportTheme.BulletAndListParagraphStyle
        }
    }
    
    var splitLineParagraphStyle: NSParagraphStyle {
        get {
            return RTFExportTheme.SplitLineParagraphStyle
        }
    }
    
    var fontSize: CGFloat {
        get {
            return RTFExportTheme.NormalFontSize
        }
    }
    
    var bodyFont: UIFont {
        get {
            return RTFExportTheme.NormalFont
        }
    }
    
    var bodyBoldFont: UIFont {
        get {
            return RTFExportTheme.BoldNormalFont
        }
    }
    
    var bodyItalicFont: UIFont {
        get {
            return RTFExportTheme.ItalicNormalFont
        }
    }
    
    func headerFont(type: TextHeaderType) -> UIFont {
        switch type {
        case .H1:
            return RTFExportTheme.HeaderFont1
        case .H2:
            return RTFExportTheme.HeaderFont2
        case .H3:
            return RTFExportTheme.HeaderFont3
        case .Other:
            return RTFExportTheme.HeaderFont3
        default:
            return RTFExportTheme.HeaderFont3
        }
    }
    
    var subscriptFont: UIFont {
        get {
            return RTFExportTheme.SubscriptFont
        }
    }
    
    var emptyFont: UIFont {
        get {
            return RTFExportTheme.BoldNormalFont
        }
    }
    
    var syntaxReplacementFont: UIFont {
        get {
            return RTFExportTheme.SyntaxReplacementFont
        }
    }
    
    var highlightColor: UIColor {
        get {
            return RTFExportTheme.HighlightColor
        }
    }
    
    var highlightTextColor: UIColor {
        get {
            return RTFExportTheme.HighlightTextColor
        }
    }
    
    var bodyColor: UIColor {
        get {
            return RTFExportTheme.NormalTextColor
        }
    }
    
    var headerColor: UIColor {
        get {
            return RTFExportTheme.HeaderTextColor
        }
    }
    
    var linkColor: UIColor {
        get {
            return RTFExportTheme.LinkColor
        }
    }
    
    var hashTagForegroundColor: UIColor {
        get {
            return RTFExportTheme.HashTagForegroundColor
        }
    }
    
    var hashTagBackgroundColor: UIColor {
        get {
            return RTFExportTheme.HashTagBackgroundColor
        }
    }
    
    var syntaxColor: UIColor {
        get {
            return RTFExportTheme.SyntaxColor
        }
    }
    
    var bulletAndListColor: UIColor {
        get {
            return RTFExportTheme.BulletAndListColor
        }
    }
    
    var codeForegroundColor: UIColor {
        get {
            return RTFExportTheme.CodeForegroundColor
        }
    }
    
    var codeBackgroundStrokeColor: UIColor {
        get {
            return RTFExportTheme.CodeBackgroundStrokeColor
        }
    }
    
    var codeBackgroundFillColor: UIColor {
        get {
            return RTFExportTheme.CodeBackgroundFillColor
        }
    }
    
    var codeBodyFont: UIFont {
        get {
            return RTFExportTheme.CodeFont
        }
    }
    
    var splitLineColor: UIColor {
        get {
            return RTFExportTheme.SplitLineColor
        }
    }
    
    // MARK: - Color Settings
    private static let BackgroundColor = UIColor.white
    private static let NormalTextColor = UIColor.black
    private static let HeaderTextColor = UIColor.black
    private static let HashTagForegroundColor = UIColor.black
    private static let HashTagBackgroundColor = UIColor.lightGray
    private static let HighlightColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    private static let HighlightTextColor = UIColor.white
    private static let SyntaxColor = UIColor.black
    private static let LinkColor = UIColor.orange
    private static let BulletAndListColor = UIColor.white
    private static let CodeBackgroundStrokeColor = UIColor.darkGray
    private static let CodeBackgroundFillColor = UIColor.darkGray
    private static let CodeForegroundColor = UIColor.white
    private static let SplitLineColor = UIColor.white
    
    // MARK: - Font Settings
    
    // font size settings
    private static let NormalFontSize = CGFloat(16)
    private static let HeaderFontSize = CGFloat(30)
    private static let SubscriptFontSize = CGFloat(8)
    
    // body fonts
    private static let NormalFontDescriptor = UIFontDescriptor(name: "Avenir Next", size: NormalFontSize)
    private static let NormalFont = UIFont(descriptor: NormalFontDescriptor, size: NormalFontSize)
    private static let BoldNormalFont = UIFont(descriptor: NormalFontDescriptor.withSymbolicTraits(.traitBold)!, size: NormalFontSize)
    private static let ItalicNormalFont = UIFont(descriptor: NormalFontDescriptor.withSymbolicTraits(.traitItalic)!, size: NormalFontSize)
    private static let CodeFontDescriptor = UIFontDescriptor(name: "System", size: NormalFontSize)
    private static let CodeFont = UIFont(descriptor: CodeFontDescriptor, size: NormalFontSize)
    
    // header fonts
    private static let HeaderFontDescriptor = UIFontDescriptor(name: "Avevir Next", size: HeaderFontSize)
    private static let HeaderFont1 = UIFont(descriptor: NormalFontDescriptor, size: HeaderFontSize)
    private static let HeaderFont2 = UIFont(descriptor: NormalFontDescriptor, size: HeaderFontSize - 5)
    private static let HeaderFont3 = UIFont(descriptor: NormalFontDescriptor, size: HeaderFontSize - 10)
    private static let SubscriptFont = UIFont(descriptor: NormalFontDescriptor, size: SubscriptFontSize)
    
    // customized fonts
    private static let EmptyfontDescriptor = UIFontDescriptor(name: "EmptyFont", size: NormalFontSize)
    private static let syntaxReplacementFontDescriptor = UIFontDescriptor(name: "SyntaxReplacementFont", size: NormalFontSize)
    private static let EmptyFont = UIFont(descriptor: EmptyfontDescriptor, size: NormalFontSize)
    private static let SyntaxReplacementFont = UIFont(descriptor: syntaxReplacementFontDescriptor, size: NormalFontSize)
    
    // MARK: - Paragraph Style Settings
    
    // paragraph settings
    private static let FirstLineHeadIndent = CGFloat(5)
    private static let HeadIndent = CGFloat(10)
    private static let TailIndent = CGFloat(-10)
    
    // header paragraph style
    private static var HeaderParagraphStyle: NSParagraphStyle {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 0.5*HeaderFontSize
            paragraphStyle.firstLineHeadIndent = HeadIndent
            paragraphStyle.headIndent = HeadIndent
            paragraphStyle.tailIndent = TailIndent
            paragraphStyle.paragraphSpacingBefore = 5
            paragraphStyle.paragraphSpacing = 0
            let tab = NSTextTab(textAlignment: .natural, location: HeadIndent, options:[:])
            paragraphStyle.tabStops = [tab]
            return paragraphStyle
        }
    }
    
    // body paragraph style
    private static var BodyParagraphStyle: NSParagraphStyle {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 0.5*NormalFontSize
            paragraphStyle.firstLineHeadIndent = HeadIndent
            paragraphStyle.headIndent = HeadIndent
            paragraphStyle.tailIndent = TailIndent
            paragraphStyle.paragraphSpacingBefore = 0
            paragraphStyle.paragraphSpacing = 0
            return paragraphStyle
        }
    }
    
    private static var BulletAndListParagraphStyle: NSParagraphStyle {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 0.5*NormalFontSize
            paragraphStyle.firstLineHeadIndent = HeadIndent
            paragraphStyle.headIndent = HeadIndent
            paragraphStyle.tailIndent = TailIndent
            paragraphStyle.paragraphSpacingBefore = 0
            paragraphStyle.paragraphSpacing = 0
            let tab = NSTextTab(textAlignment: .natural, location: HeadIndent, options:[:])
            paragraphStyle.tabStops = [tab]
            return paragraphStyle
        }
    }
    
    private static var SplitLineParagraphStyle: NSParagraphStyle {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 0.5*NormalFontSize
            paragraphStyle.firstLineHeadIndent = HeadIndent
            paragraphStyle.headIndent = HeadIndent
            paragraphStyle.tailIndent = TailIndent
            paragraphStyle.paragraphSpacingBefore = 0
            paragraphStyle.paragraphSpacing = 0
            let tab = NSTextTab(textAlignment: .right, location: HeadIndent, options:[:])
            paragraphStyle.tabStops = [tab]
            return paragraphStyle
        }
    }
}

