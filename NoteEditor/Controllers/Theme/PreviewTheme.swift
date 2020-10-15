//
//  PreviewTheme.swift
//  Note Editor
//
//  Created by Thang Pham on 8/18/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class PreviewTheme: Theme {
    
    var editorBackgroundColor: UIColor {
        get {
            return PreviewTheme.BackgroundColor
        }
    }
    
    var bodyParagraphStyle: NSParagraphStyle {
        get {
            return PreviewTheme.BodyParagraphStyle
        }
    }
    
    var headerParagraphStyle: NSParagraphStyle {
        get {
            return PreviewTheme.HeaderParagraphStyle
        }
    }
    
    var bulletAndListParagraphStyle: NSParagraphStyle {
        get {
            return PreviewTheme.BulletAndListParagraphStyle
        }
    }
    
    var splitLineParagraphStyle: NSParagraphStyle {
        get {
            return PreviewTheme.SplitLineParagraphStyle
        }
    }
    
    var fontSize: CGFloat {
        get {
            return PreviewTheme.NormalFontSize
        }
    }
    
    var bodyFont: UIFont {
        get {
            return PreviewTheme.NormalFont
        }
    }
    
    var bodyBoldFont: UIFont {
        get {
            return PreviewTheme.BoldNormalFont
        }
    }
    
    var bodyItalicFont: UIFont {
        get {
            return PreviewTheme.ItalicNormalFont
        }
    }
    
    func headerFont(type: TextHeaderType) -> UIFont {
        switch type {
        case .H1:
            return PreviewTheme.HeaderFont1
        case .H2:
            return PreviewTheme.HeaderFont2
        case .H3:
            return PreviewTheme.HeaderFont3
        case .Other:
            return PreviewTheme.HeaderFont3
        default:
            return PreviewTheme.HeaderFont3
        }
    }
    
    var subscriptFont: UIFont {
        get {
            return PreviewTheme.SubscriptFont
        }
    }
    
    var emptyFont: UIFont {
        get {
            return PreviewTheme.EmptyFont
        }
    }
    
    var syntaxReplacementFont: UIFont {
        get {
            return PreviewTheme.SyntaxReplacementFont
        }
    }
    
    var highlightColor: UIColor {
        get {
            return PreviewTheme.HighlightColor
        }
    }
    
    var highlightTextColor: UIColor {
        get {
            return PreviewTheme.HighlightTextColor
        }
    }
    
    var bodyColor: UIColor {
        get {
            return PreviewTheme.NormalTextColor
        }
    }
    
    var headerColor: UIColor {
        get {
            return PreviewTheme.HeaderTextColor
        }
    }
    
    var linkColor: UIColor {
        get {
            return PreviewTheme.LinkColor
        }
    }
    
    var hashTagForegroundColor: UIColor {
        get {
            return PreviewTheme.HashTagForegroundColor
        }
    }
    
    var hashTagBackgroundColor: UIColor {
        get {
            return PreviewTheme.HashTagBackgroundColor
        }
    }
    
    var syntaxColor: UIColor {
        get {
            return PreviewTheme.SyntaxColor
        }
    }
    
    var bulletAndListColor: UIColor {
        get {
            return PreviewTheme.BulletAndListColor
        }
    }
    
    var codeForegroundColor: UIColor {
        get {
            return PreviewTheme.CodeForegroundColor
        }
    }
    
    var codeBackgroundStrokeColor: UIColor {
        get {
            return PreviewTheme.CodeBackgroundStrokeColor
        }
    }
    
    var codeBackgroundFillColor: UIColor {
        get {
            return PreviewTheme.CodeBackgroundFillColor
        }
    }
    
    var codeBodyFont: UIFont {
        get {
            return PreviewTheme.CodeFont
        }
    }
    
    var splitLineColor: UIColor {
        get {
            return PreviewTheme.SplitLineColor
        }
    }
    
    // MARK: - Color Settings
    private static let BackgroundColor = UIColor.black
    private static let NormalTextColor = UIColor.lightText
    private static let HeaderTextColor = UIColor.lightText
    private static let HashTagForegroundColor = UIColor.white
    private static let HashTagBackgroundColor = UIColor.gray
    private static let HighlightColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    private static let HighlightTextColor = UIColor.black
    private static let SyntaxColor = UIColor.gray
    private static let LinkColor = UIColor.orange
    private static let BulletAndListColor = UIColor.white
    private static let CodeBackgroundStrokeColor = UIColor.lightText
    private static let CodeBackgroundFillColor = UIColor.lightText
    private static let CodeForegroundColor = UIColor.black
    private static let SplitLineColor = UIColor.lightGray
    
    // MARK: - Font Settings
    
    // font size settings
    private static let NormalFontSize = CGFloat(15)
    private static let HeaderFontSize = CGFloat(17)
    private static let SubscriptFontSize = CGFloat(3)
    
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
    private static let HeaderFont2 = UIFont(descriptor: NormalFontDescriptor, size: HeaderFontSize - 2)
    private static let HeaderFont3 = UIFont(descriptor: NormalFontDescriptor, size: HeaderFontSize - 3)
    private static let SubscriptFont = UIFont(descriptor: NormalFontDescriptor, size: SubscriptFontSize)
    
    // customized fonts
    private static let EmptyfontDescriptor = UIFontDescriptor(name: "EmptyFont", size: NormalFontSize)
    private static let syntaxReplacementFontDescriptor = UIFontDescriptor(name: "SyntaxReplacementFont", size: NormalFontSize)
    private static let EmptyFont = UIFont(descriptor: EmptyfontDescriptor, size: NormalFontSize)
    private static let SyntaxReplacementFont = UIFont(descriptor: syntaxReplacementFontDescriptor, size: NormalFontSize)
    
    // MARK: - Paragraph Style Settings
    
    // paragraph settings
    private static let FirstLineHeadIndent = CGFloat(3)
    private static let HeadIndent = CGFloat(10)
    private static let TailIndent = CGFloat(-10)
    
    // header paragraph style
    private static var HeaderParagraphStyle: NSParagraphStyle {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 0
            paragraphStyle.firstLineHeadIndent = FirstLineHeadIndent - 2
            paragraphStyle.headIndent = HeadIndent
            paragraphStyle.tailIndent = TailIndent
            paragraphStyle.paragraphSpacingBefore = 0
            paragraphStyle.paragraphSpacing = 0
            return paragraphStyle
        }
    }
    
    // body paragraph style
    private static var BodyParagraphStyle: NSParagraphStyle {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 0
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
            paragraphStyle.lineSpacing = 0
            paragraphStyle.firstLineHeadIndent = FirstLineHeadIndent
            paragraphStyle.headIndent = HeadIndent
            paragraphStyle.tailIndent = TailIndent
            paragraphStyle.paragraphSpacingBefore = 0
            paragraphStyle.paragraphSpacing = 0
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

