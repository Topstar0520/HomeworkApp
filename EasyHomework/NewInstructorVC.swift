//
//  EuerkaTV.swift
//  B4Grad
//
//  Created by ScaRiLiX on 10/14/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit
import Eureka
import ImageRow

class InstructorEditingModeVC: FormViewController {

    
    
    var instructorImageButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tableView.separatorColor = #colorLiteral(red: 0.4977670276, green: 0.5461138019, blue: 0.5126940554, alpha: 0.4513739224)
        navigationItem.title = "New Instructor"
        
        form +++ Section("Info")
            <<< InfoRow("InfoRow") { row in
                
                
                }.cellUpdate({ (cell, row) in
                    cell.instructorImageButton.addTarget(self, action: #selector(self.pickInstructorImage), for: .touchUpInside)
                    cell.nameTextField.addTarget(self, action: #selector(self.instructorNameDidChange(textField:)), for: .editingChanged)
                })
            <<< NameRow() { row in
                row.title = "Office Location"
                row.placeholder = "Ex: NS-7"
                row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                }.cellUpdate({ (cell, row) in
                    cell.titleLabel?.textColor = .white
                    cell.textField.textColor = .white
                })
            <<< TimeRow() { row in
                row.title = "Office Hours"
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                })
            +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete], header: "Contact", footer: "", { (section) in
                section.addButtonProvider = { section in
                    return ButtonRow() { row in
                        row.title = "Add Email"
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor = .white
                        })
                }
                section.multivaluedRowToInsertAt = { index in
                    return EmailRow() { row in
                        row.title = "Email"
                        row.placeholder = "Bob@MIT.com"
                        row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                        row.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
                        }.cellUpdate({ (cell, row) in
                            cell.textField?.textColor = .white
                            cell.textLabel?.textColor = .white
                        })
                }
            })
        
            +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete], header: "", footer: "", { (section) in
                section.addButtonProvider = { section in
                    return ButtonRow() { row in
                        row.title = "Add Phone"
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor = .white
                        })
                }
                section.multivaluedRowToInsertAt = { index in
                    return PhoneRow() { row in
                        row.title = "Phone"
                        row.placeholder = "01068476461"
                        row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                        row.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
                        }.cellUpdate({ (cell, row) in
                            cell.textField?.textColor = .white
                            cell.textLabel?.textColor = .white
                        })
                }
            })
        
            +++ Section()
            <<< ButtonRow() { row in
                row.title = "Create Instructor"
                row.onCellSelection(self.dismiss)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                })
        
        form.allRows.forEach { $0.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1) }
        form.allRows.last?.baseCell.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    }
    
    func dismiss(cell: ButtonCellOf<String>, row: ButtonRow)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func instructorNameDidChange(textField: UITextField)
    {
        navigationItem.title = textField.text?.count ?? 0 > 0 ? textField.text : "New Instructor"
    }
    
    @objc func pickInstructorImage(sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default) { UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Image Pick Management
    
    func openCamera() {
        let picker = UIImagePickerController()
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
        else {
            openGallery()
        }
    }
    
    func openGallery() {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension InstructorEditingModeVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            guard let row = form.rowBy(tag: "InfoRow") as? InfoRow else { return }
            row.cell.instructorImageButton.setImage(image, for: .normal)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
}

