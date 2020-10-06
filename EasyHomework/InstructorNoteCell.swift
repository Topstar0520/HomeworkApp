//
//  InstructorNoteCell.swift
//  B4Grad
//
//  Created by ScaRiLiX on 11/3/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit
import Eureka

class InstructorNoteCell: Cell<RLMInstructor>, CellType {

    @IBOutlet weak var notesTextView: UITextView!
    
    var instructor: RLMInstructor?
    
    override func setup() {
        selectionStyle = .none
        height = { return 120 }
        instructor = row.value
        notesTextView.text = instructor?.notes ?? ""
        notesTextView.placeholder = "Feel free to write down some notes about \(row.value?.name ?? "the instructor")..."
    }
    
    override func update() {
        instructor = row.value
        notesTextView.text = instructor?.notes
        notesTextView.placeholder = "Feel free to write down some notes about \(instructor?.name ?? "the instructor")..."
    }
}

final class InstructorNoteRow: Row<InstructorNoteCell>, RowType
{
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<InstructorNoteCell>(nibName: "InstructorNoteCell")
    }
}

/// Extend UITextView and implemented UITextViewDelegate to listen for changes
extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.numberOfLines = 0
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
}
