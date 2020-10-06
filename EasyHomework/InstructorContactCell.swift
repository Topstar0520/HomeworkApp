//
//  InstructorEmailCell.swift
//  B4Grad
//
//  Created by ScaRiLiX on 11/3/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit
import Eureka
class InstructorContactCell: Cell<String>, CellType {
    
    enum InfoType
    {
        case email
        case phoneNumber
        case website
        case location
    }
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contactTypeImageView: UIImageView!
    
    var infoType: InfoType = .email
    
    override func setup() {
        selectionStyle = .none
        valueLabel.text = row.value
        
        switch infoType
        {
        case .email:
            titleLabel.text = "Email"
            contactTypeImageView.image = #imageLiteral(resourceName: "email-1")
        case .phoneNumber:
            titleLabel.text = "Phone"
            contactTypeImageView.image = #imageLiteral(resourceName: "mobile-phone")
        case .website:
            titleLabel.text = "Website"
            contactTypeImageView.image = #imageLiteral(resourceName: "Instructor Website")
        case .location:
            titleLabel.text = "Location"
            contactTypeImageView.image = #imageLiteral(resourceName: "location")
        }
    }
    
    override func update() {
        valueLabel.text = row.value
        
        switch infoType
        {
        case .email:
            titleLabel.text = "Email"
            contactTypeImageView.image = #imageLiteral(resourceName: "email-1")
        case .phoneNumber:
            titleLabel.text = "Phone"
            contactTypeImageView.image = #imageLiteral(resourceName: "mobile-phone")
        case .website:
            titleLabel.text = "Website"
            contactTypeImageView.image = #imageLiteral(resourceName: "Instructor Website")
        case .location:
            titleLabel.text = "Location"
            contactTypeImageView.image = #imageLiteral(resourceName: "location")
        }
    }
}

final class InstructorContactRow: Row<InstructorContactCell>, RowType
{
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<InstructorContactCell>(nibName: "InstructorContactCell")
    }
}
