//
//  InfoCell.swift
//  B4Grad
//
//  Created by ScaRiLiX on 10/14/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit
import Eureka


final class InstructorMakingModeInfoCell: Cell<RLMInstructor>, CellType {
    
    @IBOutlet weak var instructorImageButton: UIButton!
    @IBOutlet weak var nameTextField: B4GradTextField!
    @IBOutlet weak var roleTextField: B4GradTextField!
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setup() {
        super.setup()
        selectionStyle = .none
        instructorImageButton.imageView?.contentMode = .scaleAspectFill
        instructorImageButton.imageView?.clipsToBounds = true
        instructorImageButton.layer.cornerRadius = 50
        instructorImageButton.layer.masksToBounds = true
        
        height = { return 170 }
        
        backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
        
        instructorImageButton.layer.cornerRadius = instructorImageButton.frame.height / 2
        instructorImageButton.layer.masksToBounds = true
        
        guard let instructor = row.value else { return }
        nameTextField.text = instructor.name
        roleTextField.text = instructor.role
        guard let imageData = instructor.image as Data? else { return }
        instructorImageButton.setImage(UIImage(data: imageData), for: .normal)
    }
    
    override func update() {
        super.update()
        textLabel?.text = nil
    }
    
}

final class InfoRow: Row<InstructorMakingModeInfoCell>, RowType
{
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<InstructorMakingModeInfoCell>(nibName: "InstructorMakingModeInfoCell")
    }
}
