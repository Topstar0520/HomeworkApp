//
//  InstructorViewingModeInfoCell.swift
//  B4Grad
//
//  Created by ScaRiLiX on 10/14/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit
import Eureka

/// Delegate which listens to user's click on
/// Any of the 4 contact buttons (Text, Call, Email, Website)
/// And tell the conforming View Controller to launch the
/// Text, call, email, website Action accordingly

protocol ContactActionsDelegate: class
{
    func call(_ number: String)
    func text(_ number: String)
    func email(_ email: String)
    func website(_ website: String)
}

class InstructorViewingModeInfoCell: Cell<RLMInstructor>, CellType {
    
    @IBOutlet weak var instructorImageView: UIImageView!
    @IBOutlet weak var instructorNameLabel: UILabel!
    @IBOutlet weak var instructorRoleLabel: UILabel!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    weak var delegate: ContactActionsDelegate?
    
    override func setup() {
        super.setup()
        selectionStyle = .none
        
        backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
        
        instructorImageView.layer.cornerRadius = instructorImageView.frame.height / 2
        instructorImageView.layer.masksToBounds = true
        
        guard let instructor = row.value else { return }
        instructorNameLabel.text = instructor.name
        instructorRoleLabel.text = instructor.role
        guard let imageData = instructor.image as Data? else { return }
        instructorImageView.image = UIImage(data: imageData)
        textButton.isHidden = instructor.phonenumbers.isEmpty
        websiteButton.isHidden = instructor.websites.isEmpty
        callButton.isHidden = instructor.phonenumbers.isEmpty
        emailButton.isHidden = instructor.emails.isEmpty
        
        
        height = {
            if instructor.phonenumbers.isEmpty,
            instructor.websites.isEmpty,
            instructor.emails.isEmpty
            {
                return 180
            }
            return 280
        }
    }
    
    override func update() {
        super.update()
        textLabel?.text = nil
        
        guard let instructor = row.value else { return }
        instructorNameLabel.text = instructor.name
        instructorRoleLabel.text = instructor.role
        guard let imageData = instructor.image as Data? else { return }
        instructorImageView.image = UIImage(data: imageData)
        textButton.isHidden = instructor.phonenumbers.isEmpty
        websiteButton.isHidden = instructor.websites.isEmpty
        callButton.isHidden = instructor.phonenumbers.isEmpty
        emailButton.isHidden = instructor.emails.isEmpty
        
        height = {
            if instructor.phonenumbers.isEmpty,
                instructor.websites.isEmpty,
                instructor.emails.isEmpty
            {
                return 180
            }
            return 280
        }
    }
    
    @IBAction func didTapTextInstructor(_ sender: Any) {
        guard let instructor = row.value, let phonenumber = instructor.phonenumbers.first else { return }
        print("should be texting \(phonenumber) now...")
        delegate?.text(phonenumber)
    }
    
    @IBAction func didTapCallInstructor(_ sender: Any) {
        guard let instructor = row.value, let phonenumber = instructor.phonenumbers.first else { return }
        print("should be calling \(phonenumber) now...")
        delegate?.call(phonenumber)
    }
    
    @IBAction func didTapEmailInstructor(_ sender: Any) {
        guard let instructor = row.value, let email = instructor.emails.first else { return }
        print("should be sending an email to \(email) now...")
        delegate?.email(email)
    }
    
    @IBAction func didTapInstructorWebsite(_ sender: Any) {
        guard let instructor = row.value, let website = instructor.websites.first else { return }
        print("should be opening \(website)")
        delegate?.website(website)
    }
    
    
    
    
}

final class InstructorViewingModeInfoRow: Row<InstructorViewingModeInfoCell>, RowType
{
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<InstructorViewingModeInfoCell>(nibName: "InstructorViewingModeInfoCell")
    }
}
