//
//  InstructorTableViewCell.swift
//  B4Grad
//
//  Created by ScaRiLiX on 10/15/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

class InstructorTableViewCell: UITableViewCell {

    
    @IBOutlet weak var instructorImageView: UIImageView!
    @IBOutlet weak var instructorNameLabel: UILabel!
    @IBOutlet weak var instructorRoleLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    //var instructor: RLMInstructor?
    
    var instructor: RLMInstructor?
    {
        didSet
        {
            instructorNameLabel.text = instructor?.name
            instructorRoleLabel.text = instructor?.role
            guard let imageData = instructor?.image as Data? else { return }
            instructorImageView.image = UIImage(data: imageData)
            
            callButton.isHidden = instructor?.phonenumbers.isEmpty ?? true
            emailButton.isHidden = instructor?.emails.isEmpty ?? true
            websiteButton.isHidden = instructor?.websites.isEmpty ?? true
        }
    }
    
    weak var delegate: ContactActionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        instructorImageView.layer.cornerRadius = instructorImageView.frame.height / 2
        instructorImageView.layer.masksToBounds = true
    }
    
    @IBAction func didTapCallInstructor(_ sender: Any) {
        guard let instructorPhone = instructor?.phonenumbers.first else { return }
        delegate?.call(instructorPhone)
    }
    
    @IBAction func didTapEmailInstructor(_ sender: Any) {
        guard let instructorEmail = instructor?.emails.first else { return }
        delegate?.email(instructorEmail)
    }
    
    @IBAction func didTapWebsiteButton(_ sender: Any) {
        guard let website = instructor?.websites.first else { return }
        delegate?.website(website)
    }
    
    
}
