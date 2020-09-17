//
//  NoteEditor.swift
//  Note Editor
//
//  Created by Thang Pham on 8/16/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

protocol NoteEditorDelegate: NSObjectProtocol {
    func requestUserInputPhoto(sender: NoteEditor, completion: ((_ imageName: String?) -> Void)?)
    func requestUserInputHyperlink(sender: NoteEditor, preemptedTitle: String, preemptedLink: String, completion: ((_ title: String?, _ hyperlink: String?) -> Void)?)
    func requestUserInputAttachedFile(sender: NoteEditor, completion: ((_ fileName: String?) -> Void)?)
    func requestUserInputHeaderType(sender: NoteEditor, completion: ((_ headerType:TextHeaderType) -> Void)?)
}

class NoteEditor: NSObject {
    private weak var delegate: NoteEditorDelegate!
    var noteFile: NoteFile!
    var editActions: [EditAction]!
    var textView: NETextView!
    private var newLineAction: NewLineAction!
    private var replaceTextAction: ReplaceTextAction!
    private var insertTextAction: InsertTextAction!
   // private var truncateHeaderAction: TruncateHeaderAction!
   // private var crossLineAction: TickCheckboxAction!
   // private var editHyperLinkAction: EditHyperlinkAction!
   // private var editHeaderAction: EditHeaderAction!
   // private var truncateAttachmentAction: TruncateAttachmentAction!
   // private var truncateSplitLineAction: TruncateSplitLineAction!
    private var noteDescriptor: NoteDescriptor!
    
    // MARK: - Init
    
    init(delegate: NoteEditorDelegate, textView: NETextView) {
        super.init()
        self.delegate = delegate
        self.textView = textView
        self.textView.backgroundColor = ThemeCenter.theme.editorBackgroundColor
        self.addDefaultEditActions()
    }
    
    private func addDefaultEditActions() {
        newLineAction = NewLineAction(editor: self)
        replaceTextAction = ReplaceTextAction(editor: self)
        insertTextAction = InsertTextAction(editor: self)
     //   truncateHeaderAction = TruncateHeaderAction(editor: self)
    //    truncateSplitLineAction = TruncateSplitLineAction(editor: self)
    //    truncateAttachmentAction = TruncateAttachmentAction(editor: self)
    //    crossLineAction = TickCheckboxAction(editor: self)
    //    editHeaderAction = EditHeaderAction(editor: self)
    //    editHyperLinkAction = EditHyperlinkAction(editor: self)
        editActions =
            [

             UndoAction(editor: self),
             RedoAction(editor: self),
             
             MakeTextBoldAction(editor: self),
             MakeTextItalicAction(editor: self),
             MakeTextUnderlineAction(editor: self),
             MakeTextStrikeThroughAction(editor: self),
             HighlightTextAction(editor: self),
             
//             AddHashTagAction(editor: self),
            // MakeHeaderAction(editor: self),
            // InsertDividerAction(editor: self),
             
//             AddBulletPointsAction(editor: self),
//             AddNumberListAction(editor: self),
//             AddBlockQuoteAction(editor: self),
//             AddCheckboxAction(editor: self),
//             InsertCodeAction(editor: self),
//             MakeBlockCodeAction(editor: self),
//
//             InsertHyperlinkAction(editor: self),
//             InsertPhotoAction(editor: self),
//             AttachFileAction(editor: self),
//
//             DecreaseLineIndentAction(editor: self),
//             IncreaseLineIndentAction(editor: self),
//             MoveLineUp(editor: self),
//             MoveLineDown(editor: self),
//             MoveCursorUpAction(editor: self),
//             MoveCursorDownAction(editor: self),
//             MoveCursorLeftAction(editor: self),
//             MoveCursorRightAction(editor: self)
        ]
    }
    
    // MARK: - I/O operations

    func openFromNoteFile(_ descriptor: NoteDescriptor, completion: ((Bool) -> Void)?){
        noteFile = NoteFile(noteDescriptor: descriptor)
        
        AttachmentLinkBuilder.instance.noteDescriptor = descriptor
        noteDescriptor = descriptor
        noteFile.open { [weak self] (success) in
            if success {
                // apply default styles
                if let weakSelf = self {
                    DispatchQueue.main.async {
                        let _ = SyntaxStylizer.stylizeSyntaxElements(range: NSMakeRange(0, weakSelf.noteFile.attrs.length), attrs: weakSelf.noteFile.attrs, checkingStr: weakSelf.noteFile.attrs.string)
                        
                        weakSelf.textView.attributedText = weakSelf.noteFile.attrs
                        weakSelf.checkWetherEditorIsEmpty()
                    }
                }
            }else {
                if let weakSelf = self {
                    weakSelf.checkWetherEditorIsEmpty()
                }
            }
            completion?(success)
            self?.noteFile.close(completionHandler: nil)
        }
    }

    func saveToNoteFile(completion: ((Bool) -> Void)?) {
        let mutableAttrs = NSMutableAttributedString(attributedString: textView.textStorage)
        let scanningRange = SyntaxStylizer.removeAttachments(in: NSMakeRange(0, mutableAttrs.length), attrs: mutableAttrs)
        _ = SyntaxStylizer.removeTabs(in: scanningRange, attrs: mutableAttrs)
        noteFile.attrs = mutableAttrs

        noteDescriptor.overview = (noteFile.attrs.string as NSString).substring(with: NSMakeRange(0, min(150, noteFile.attrs.length)))
        
        (noteFile.attrs.string as NSString).enumerateLines { (line, stop) in
            self.noteDescriptor.title = line
            stop.pointee = true
        }
        let images = NEFileManager.getImagesFromAssetFolder(noteId: noteDescriptor.id)
        for (idx, image) in images.enumerated() {
            if idx == 0 { noteDescriptor.descImage1 = image }
            else if idx == 1 { noteDescriptor.descImage2 = image }
            else { break }
        }
        //EditorDB.sharedInstance.saveObject(descriptor, type: .NoteDescriptor)
        noteFile.save(to: noteFile.fileURL, for: .forOverwriting) { (success) in
            completion?(success)
        }
    }
    
    // MARK: - Actions

    func doAction(at index: Int, selectedRange: NSRange) {
      //  let cursorPosition = textView.caretRect(for: (textView.selectedTextRange?.start)!).origin
        editActions[index].execute(in: selectedRange, with: textView.textStorage,textview:textView)
    }
    
    

    func doEditHeader(selectedRange: NSRange) {
       // editHeaderAction.execute(in: selectedRange, with: textView.textStorage)
    }
    
    func doEditHyperLink(selectedRange: NSRange) {
   //     editHyperLinkAction.execute(in: selectedRange, with: textView.textStorage)
    }
    
    func crossLine(selectedRange: NSRange) {
//        crossLineAction.execute(in: NSMakeRange(selectedRange.location, 0) , with: textView.textStorage)
    }
    
    func setSelectedRange(_ range: NSRange) {
       textView.selectedRange = range
    }
    
    


    func changeText(in range: NSRange, replacementText replaceText: String, selectedRange: NSRange) {
        print("replace:",replaceText)
        let replaceAttrs = NSAttributedString(string: replaceText)
         var isFound = Bool()
     /*   if let selectedRange = textView.selectedTextRange, replaceText != " " {
            
            let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            
            print("\(cursorPosition)")
            
            if cursorPosition > 2{
                print(textView.attributedText.attributedSubstring(from: NSRange(location: cursorPosition-1, length: 1)).string)
                
                if((textView.attributedText.attributedSubstring(from: NSRange(location: cursorPosition-1, length: 1)).string) == "-"){
                    var currentChar = ""
                    var counter = cursorPosition-2
                   
                    while(counter != -1){
                        
                        currentChar = (textView.attributedText.attributedSubstring(from: NSRange(location: counter, length: 1)).string)
                        if(currentChar == "-"){
                            isFound = true
                            break
                        }
                        else{
                            
                            isFound = false
                        }
                        print(currentChar)
                        print(counter)
                        counter -= 1
                        
                    }
                    
                    if(isFound){
                        
                        print("found at position \(counter)")
                        
                        
                        
                        let removedRange = NSRange(location: counter, length: cursorPosition-counter)
                        
                        let textStorage = NSMutableAttributedString(attributedString: textView.textStorage)
                        textStorage.beginEditing()
                        textStorage.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: ThemeCenter.theme.bodyColor, NSAttributedString.Key.backgroundColor: ThemeCenter.theme.editorBackgroundColor, NSAttributedString.Key.paragraphStyle: ThemeCenter.theme.bodyParagraphStyle,
                                             NSAttributedString.Key.strikethroughStyle: 0
                            ], range: removedRange)
                            textStorage.endEditing()
                        
                        var attributes = [NSAttributedStringKey : Any]()
                        for (key, value) in textView!.typingAttributes {
                            attributes[NSAttributedString.Key(rawValue: key)] = value
                        }
//                        let attrs = NSMutableAttributedString(string: replaceText, attributes: textStorage.)
                        
                         self.implReplaceCharacters(in: removedRange, with: textStorage, set: NSMakeRange(range.location + replaceAttrs.length, 0))
                       
                        return
                    }
                    
                   
                    
                    
                    
                }
            }
        }*/
        if replaceText == ""{ // delete texts
            /*if range.location > 2 && textView.textStorage.attributedSubstring(from: NSMakeRange(range.location - 2, 3)).string == "---"  {
                truncateSplitLineAction.execute(in: range, with: textView.textStorage)
            }else if MarkupSyntaxTruncater.instance.isHeader(in: (textView.textStorage.string as NSString).lineRange(for: range), with: textView.textStorage) {
                if (textView.textStorage.string as NSString).lineRange(for: range).location != 0 {
                    truncateHeaderAction.execute(in: NSMakeRange(range.location, replaceAttrs.length), with: textView.textStorage)
                }
            }else {*/
                var willTruncateAttachment = false
                textView.textStorage.enumerateAttribute(.attachment, in: range, options: .longestEffectiveRangeNotRequired) { (value, matchRange, stop) in
                    if let _ = value as? NSTextAttachment {
                        willTruncateAttachment = true
                    }
                }
                if !willTruncateAttachment {
                    var location = selectedRange.location
                    if selectedRange.length == 0 && location > 0 {
                        location -= 1
                    }
                    replaceTextAction.execute(in: range, with: NSAttributedString(string:""), textview: textView)
                }/*else {
                    truncateAttachmentAction.execute(in: range, with: textView.textStorage)
                }*/
            //}
        }else if replaceText == "\n" { // enter a new line
            self.newLineAction.execute(in: NSMakeRange(textView.selectedRange.location, 0), with: textView.textStorage, textview: textView)
        }else if range.length == 0 { // insert new text
            let specialCharSet = CharacterSet.newlines.union(CharacterSet(charactersIn: "/*-][:_.`+>#"))
            let nearestChar = range.location > 0 ? (textView.text as NSString).substring(with: NSMakeRange(range.location - 1, 1)): nil
    
            if (nearestChar != nil && nearestChar! == "\t") {
                insertTextAction.execute(in: range, with: replaceAttrs, textview: textView)
            }else if (replaceText.rangeOfCharacter(from: specialCharSet) != nil) || (nearestChar != nil && nearestChar!.rangeOfCharacter(from: specialCharSet) != nil) {
                insertTextAction.execute(in: range, with: replaceAttrs, textview: textView)
            }else {
                // bypass formatting process
                var attributes = [NSAttributedStringKey : Any]()
                for (key, value) in textView!.typingAttributes {
                    attributes[NSAttributedString.Key(rawValue: key)] = value
                }
     
                let attrs = NSMutableAttributedString(string: replaceText, attributes: attributes)
                print("attrs String:",attrs.string)
                print("attrs :",attrs)
                insertTextAction.execute(in: range, with: replaceAttrs, textview: textView)
               // self.implReplaceCharacters(in: range, with: attrs, set: NSMakeRange(range.location + replaceAttrs.length, 0))
            }

        }else { // replace a text
            replaceTextAction.execute(in: range, with: replaceAttrs, textview: textView)
        }
    }

    func checkWetherEditorIsEmpty() {
        //ThemeCenter.theme.bodyFont
        //UIFont.systemFont(ofSize: 25)
        //ThemeCenter.theme.bodyColor
    
        if textView.textStorage.string.count == 0 {
            textView!.typingAttributes = [NSAttributedString.Key.font.rawValue: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor.rawValue: UIColor.white, NSAttributedString.Key.paragraphStyle.rawValue: ThemeCenter.theme.bodyParagraphStyle
            ]
            //insertTextAction.execute(in: NSMakeRange(0, 0), with: NSMutableAttributedString(string: "# "))
        }
    }
    
    // MARK: Request User Input
    
    func requestPhoto(completion: ((_ imageName: String?) -> Void)?) {
        self.delegate.requestUserInputPhoto(sender: self) { (imageName) in
            completion?(imageName)
        }
    }
    
    func requestHyperlink(preemptedTitle: String, preemptedLink: String, completion: ((_ title: String?, _ hyperlink: String? ) -> Void)?) {
        self.delegate.requestUserInputHyperlink(sender: self, preemptedTitle: preemptedTitle, preemptedLink: preemptedLink) { (title, hyperlink) in
            completion?(title, hyperlink)
        }
    }
    
    func requestFileAttachment(completion: ((_ fileName: String?) -> Void)?) {
        self.delegate.requestUserInputAttachedFile(sender: self) { (fileName) in
            completion?(fileName)
        }
    }
    
    func requestHeaderType(completion: ((_ headerType: TextHeaderType) -> Void)?) {
        self.delegate.requestUserInputHeaderType(sender: self) { (headerType) in
            completion?(headerType)
        }
    }

    // MARK: Rollback handlers
    
    func redo() {
        textView.undoManager?.redo()
    }
    
    func undo() {
        textView.undoManager?.undo()
    }
    
    // MARK: BackingStore editing
    
    func replaceCharacters(in range:NSRange, with attrs: NSAttributedString, set selectedRange: NSRange?) {
        let textStorage = NSMutableAttributedString(attributedString: textView.textStorage)
        textStorage.replaceCharacters(in: range, with: attrs)
        var (originalRange, modifiedRange) = SyntaxStylizer.processEditing(attrs: textStorage, editedRange: NSMakeRange(range.location, attrs.length))
        originalRange.length += range.length - attrs.length
        implReplaceCharacters(in: originalRange, with: textStorage.attributedSubstring(from: modifiedRange), set: selectedRange)
    }
    
    func implReplaceCharacters(in range:NSRange, with attrs: NSAttributedString, set selectedRange: NSRange?) {
        let undoSelectedRange = self.textView.selectedRange
        let undoRange = NSMakeRange(range.location, attrs.length)
        let undoAttrs = self.textView.textStorage.attributedSubstring(from: range)
        self.textView.undoManager?.registerUndo(withTarget: self) {targetSelf in
            targetSelf.implReplaceCharacters(in: undoRange, with: undoAttrs, set: undoSelectedRange)
        }
        
        self.textView.undoManager?.setActionName("Replace Characters")
        if (range.length > 0) {
            self.textView.textStorage.replaceCharacters(in: range, with: attrs)
        }else {
            self.textView.textStorage.insert(attrs, at: range.location)
        }
        if selectedRange != nil {
            self.textView.selectedRange = selectedRange!
        }
    }

}
