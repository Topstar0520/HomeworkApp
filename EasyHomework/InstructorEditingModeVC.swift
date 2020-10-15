//
//  InstructorEditingModeVC.swift
//  B4Grad
//
//  Created by ScaRiLiX on 10/14/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit
import Eureka
import MessageUI
import RealmSwift

class InstructorEditingModeVC: FormViewController, UITextFieldDelegate {
    
    enum EditingMode
    {
        case creating
        case editing
    }
    
    var instructor: RLMInstructor?
    var course: RLMCourse!
    var type: String!
    var editingMode: EditingMode?
    var weeklyEditingVC: WeeklyEditingTableViewController?
    
    var profileImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tableView.separatorColor = #colorLiteral(red: 0.4977670276, green: 0.5461138019, blue: 0.5126940554, alpha: 0.4513739224)
        navigationItem.title = (editingMode == .creating) ? "New Instructor" : "Instructor"
        if editingMode == .editing
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneWithEditing))
        }
        else
        {
            navigationItem.rightBarButtonItem = nil
        }
        
        
        form +++ Section()
            <<< InfoRow("InfoRow") { row in
                row.value = instructor
                row.cell.nameTextField.keyboardAppearance = .dark
                row.cell.nameTextField.returnKeyType = .done
                row.cell.nameTextField.delegate = self
                row.cell.roleTextField.keyboardAppearance = .dark
                row.cell.roleTextField.returnKeyType = .done
                row.cell.roleTextField.delegate = self
                }.cellUpdate({ (cell, row) in
                    cell.nameTextField.addTarget(self, action: #selector(self.instructorNameDidChange), for: UIControlEvents.editingChanged)
                    cell.instructorImageButton.addTarget(self, action: #selector(self.pickInstructorImage(sender:)), for: .touchUpInside)
                })
            <<< NameRow("LocationRow") { row in
                row.title = "Office Location"
                row.placeholder = "Ex: NS-7"
                row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                row.value = self.instructor?.location
                row.cell.textField?.keyboardAppearance = .dark
                
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                    cell.textField?.textColor = .white
                })
            <<< TimeRow("FromHoursRow") { row in
                row.title = "Start Time"
                if (self.instructor?.hours != nil && self.instructor?.hours != "") {
                    let hours = self.instructor!.hours
                    let hour = hours.components(separatedBy: "-")[0]
                    let date = dateFromString(date: hour, format: "hh:mm a")
                    row.value = date
                } else {
                    let defaultDateString = "8:00 AM"
                    let date = dateFromString(date: defaultDateString, format: "hh:mm a")
                    row.value = date
                }
                row.cell.datePicker.backgroundColor = UIColor.black
                row.cell.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
                row.cell.datePicker.setValue(0.8, forKeyPath: "alpha")
                
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                    row.cell.datePicker.backgroundColor = UIColor.black
                    row.cell.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
                    row.cell.datePicker.setValue(0.8, forKeyPath: "alpha")
                })
            <<< TimeRow("ToHoursRow") { row in
                row.title = "End Time"
                if (self.instructor?.hours != nil && self.instructor?.hours != "") {
                    let hours = self.instructor!.hours
                    let hour = hours.components(separatedBy: "-")[1]
                    let date = dateFromString(date: hour, format: "hh:mm a")
                    row.value = date
                } else {
                    let defaultDateString = "9:00 AM"
                    let date = dateFromString(date: defaultDateString, format: "hh:mm a")
                    row.value = date
                }
                row.cell.datePicker.backgroundColor = UIColor.black
                row.cell.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
                row.cell.datePicker.setValue(0.8, forKeyPath: "alpha")
                
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                    row.cell.datePicker.backgroundColor = UIColor.black
                    row.cell.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
                    row.cell.datePicker.setValue(0.8, forKeyPath: "alpha")
                })
            +++
            MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete], header: "Contact", footer: "") { section in
                
                section.addButtonProvider = { section in
                    return ButtonRow(){ row in
                        row.title = "New Email"
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor = .white
                            cell.textLabel?.textAlignment = .left
                        })
                }
                if editingMode == .creating
                {
                    section.multivaluedRowToInsertAt = { index in
                        return EmailRow("Email\(index)") { row in
                            row.title = "Email"
                            row.placeholder = "hello@urw.com"
                            row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                            row.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
                            row.cell.textField?.keyboardAppearance = .dark
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                                cell.textField?.textColor = .white
                            })
                        
                    }
                }
                else
                {
                    section.multivaluedRowToInsertAt = { index in
                        return EmailRow("Email\(index)") { row in
                            row.title = "Email"
                            row.placeholder = "hello@urw.com"
                            row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                            row.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
                            row.cell.textField?.keyboardAppearance = .dark
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                                cell.textField?.textColor = .white
                            })
                        
                    }
                    
                    instructor?.emails.enumerated().forEach({ (index, email) in
                        section <<< EmailRow("Email\(index)") { row in
                            row.title = "Email"
                            row.placeholder = "contact@b4grad.com"
                            row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                            row.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
                            row.value = email
                            row.cell.textField?.keyboardAppearance = .dark
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                                cell.textField?.textColor = .white
                            })
                    })
                }
            }
            +++
            MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete], header: "", footer: "") { section in
                
                section.addButtonProvider = { section in
                    return ButtonRow(){ row in
                        row.title = "New Phone"
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor = .white
                            cell.textLabel?.textAlignment = .left
                        })
                }
                if editingMode == .creating
                {
                    section.multivaluedRowToInsertAt = { index in
                        return PhoneRow("Phone\(index)") { row in
                            row.title = "Phone"
                            row.placeholder = "(000) 123-4567"
                            row.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
                            row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                            row.cell.textField?.keyboardAppearance = .dark
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                                cell.textField?.textColor = .white
                            })
                    }
                }
                else
                {
                    section.multivaluedRowToInsertAt = { index in
                        return PhoneRow("Phone\(index)") { row in
                            row.title = "Phone"
                            row.placeholder = "(000) 123-4567"
                            row.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
                            row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                            row.cell.textField?.keyboardAppearance = .dark
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                                cell.textField?.textColor = .white
                            })
                    }
                    
                    instructor?.phonenumbers.enumerated().forEach({ (index, phonenumber) in
                        section <<< PhoneRow("Phone\(index)") { row in
                            row.title = "Phone"
                            row.placeholder = "(000) 123-4567"
                            row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                            row.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
                            row.value = phonenumber
                            row.cell.textField?.keyboardAppearance = .dark
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                                cell.textField?.textColor = .white
                            })
                    })
                }
            }
            +++
            MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete], header: "", footer: "") { section in
                
                section.addButtonProvider = { section in
                    return ButtonRow(){ row in
                        row.title = "New Website"
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor = .white
                            cell.textLabel?.textAlignment = .left
                        })
                }
                if editingMode == .creating
                {
                    section.multivaluedRowToInsertAt = { index in
                        return URLRow("Website\(index)") { row in
                            row.title = "Website"
                            row.placeholder = "www.B4Grad.com"
                            row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                            row.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
                            row.cell.textField?.keyboardAppearance = .dark
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                                cell.textField.textColor = .white
                            })
                        
                    }
                }
                else
                {
                    section.multivaluedRowToInsertAt = { index in
                        return URLRow("Website\(index)") { row in
                            row.title = "Website"
                            row.placeholder = "www.B4Grad.com"
                            row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                            row.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
                            row.cell.textField?.keyboardAppearance = .dark
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                                cell.textField.textColor = .white
                            })
                        
                    }
                    
                    instructor?.websites.enumerated().forEach({ (index, website) in
                        section <<< URLRow("Website\(index)") { row in
                            row.title = "Website"
                            row.placeholder = "www.B4Grad.com"
                            row.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                            row.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
                            row.value = website.toURL() as URL?
                            row.cell.textField?.keyboardAppearance = .dark
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                                cell.textField.textColor = .white
                            })
                    })
                }
            }
            +++ Section()
            <<< ButtonRow() { row in
                row.title = (editingMode == .creating) ? "Create Instructor" : "Confirm"
                
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                    
                }).onCellSelection({ (_, _) in
                    (self.editingMode == .creating) ? self.createInstructor() : self.completeEditing()
                })
        
        
        form.allRows.forEach { $0.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1) }
        form.allRows.forEach {
            $0.baseCell.selectedBackgroundView = UIView()
            $0.baseCell.selectedBackgroundView?.backgroundColor = UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1.0)
        }
        
        form.allRows.last?.baseCell.backgroundColor = (editingMode == .creating) ? #colorLiteral(red: 0.07450980392, green: 0.5058823529, blue: 0.7490196078, alpha: 1) : #colorLiteral(red: 0, green: 0.4980392157, blue: 0.1411764706, alpha: 1)
        
    }
    
    fileprivate func getOfficeHours(_ instructor: RLMInstructor) {
        if let fromTimeRow = form.rowBy(tag: "FromHoursRow") as? TimeRow, let fromHours = fromTimeRow.value?.timeString(ofStyle: .short)
        {
            if let toTimeRow = form.rowBy(tag: "ToHoursRow") as? TimeRow, let toHours = toTimeRow.value?.timeString(ofStyle: .short)
            {
                let hours = fromHours + "-" + toHours
                instructor.hours = hours
            }
        }
    }
    
    fileprivate func getOfficeLocation(_ instructor: RLMInstructor) {
        if let locationRow = form.rowBy(tag: "LocationRow") as? NameRow
        {
            let location = locationRow.cell.textField.text ?? "No Location"
            instructor.location = location
        }
    }
    
    fileprivate func getInfo(_ instructor: RLMInstructor) {
        if let infoRow = form.rowBy(tag: "InfoRow") as? InfoRow
        {
            guard let name = infoRow.cell!.nameTextField.text else { return }
            guard let role = infoRow.cell!.roleTextField.text else { return }
            
            instructor.name = name
            instructor.role = role
            
            let image = infoRow.cell!.instructorImageButton.imageView?.image ?? #imageLiteral(resourceName: "ProfileImage")
            guard let imageData = UIImagePNGRepresentation(image) else { return }
            
            if image != nil {
                var imageData = UIImagePNGRepresentation(image)
                if (imageData!.count > 2097152) {
                    let newImage = UIImage(data: imageData!)
                    imageData = UIImageJPEGRepresentation(newImage!, 0.5)
                }
                //We are currently saving the image into realm. This is a poor practice, and in the future this code should be modified so that we are saving the uri of the file to realm, and the image itself is saved to the App's Documents Folder. Delete this comment if this modification has been made.
                //Make sure to also change the code in the doneEditing method.
                if (imageData!.count < 2097152) {
                    instructor.image = imageData
                }
            }
        }
    }
    
    /// Get Emails, Phone Numbers and/or Websites of the instructor
    fileprivate func getValues(_ instructor: RLMInstructor) {
        let values = form.values().filter { (key, value) -> Bool in
            return key.contains("Phone") || key.contains("Email") || key.contains("Website")
        }
        
        values.forEach { (key, value) in
            if key.contains("Phone")
            {
                guard let phonenumber = value as? String else { return }
                instructor.phonenumbers.append(phonenumber)
            }
            else if key.contains("Email")
            {
                guard let email = value as? String else { return }
                instructor.emails.append(email)
            }
            else if key.contains("Website")
            {
                guard let website = (value as? URL)?.absoluteString else { return }
                instructor.websites.append(website)
            }
        }
    }
    
    func createInstructor()
    {
        guard let course = self.course else { return }
        let instructor = RLMInstructor()
        instructor.course = self.course
        instructor.type = self.type

        //getInfo(instructor)
        let infoRow = form.rowBy(tag: "InfoRow") as! InfoRow
        let name = infoRow.cell!.nameTextField!.text!
        let role = infoRow.cell!.roleTextField!.text!
        
        instructor.name = name
        instructor.role = role
        
        
        if self.profileImage != nil {
            var imageData = UIImagePNGRepresentation(self.profileImage!)
            if (imageData!.count > 2097152) {
                let newImage = UIImage(data: imageData!)
                imageData = UIImageJPEGRepresentation(newImage!, 0.7)
            }
            //We are currently saving the image into realm. This is a poor practice, and in the future this code should be modified so that we are saving the uri of the file to realm, and the image itself is saved to the App's Documents Folder. Delete this comment if this modification has been made.
            //Make sure to also change the code in the doneEditing method.
            if (imageData!.count < 2097152) {
                instructor.image = imageData
            }
        }
        
        //getOfficeLocation(instructor)
        
        let locationRow = form.rowBy(tag: "LocationRow") as! NameRow
        if (locationRow.cell!.textField.text != nil) {
            instructor.location = locationRow.cell!.textField.text!
        }
        
        //getOfficeHours(instructor)
        
        let fromTimeRow = form.rowBy(tag: "FromHoursRow") as! TimeRow
        let toTimeRow = form.rowBy(tag: "ToHoursRow") as! TimeRow
        if (fromTimeRow.value != nil && toTimeRow.value != nil) {
            if (fromTimeRow.value is Date && toTimeRow.value is Date) {
                let fromHours = fromTimeRow.value!.timeString(ofStyle: .short)
                let toHours = toTimeRow.value!.timeString(ofStyle: .short)
                let hours = fromHours + "-" + toHours //"\(fromHours) - \(toHours)"
                instructor.hours = hours
            }
        }
        
        //getValues(instructor)
        
        /*let values = form.values().filter { (key, value) -> Bool in
            return key.contains("Phone") || key.contains("Email") || key.contains("Website")
        }*/
        form.values().forEach { (key, value) in // form.values().forEach { (key, value) in
            if key.contains("Phone") {
                if (value != nil) {
                    instructor.phonenumbers.append(value as! String)
                }
            } else if key.contains("Email") {
                 if (value != nil) {
                    instructor.emails.append(value as! String)
                }
            } else if key.contains("Website") {
                if (value != nil && value is URL) {
                    let urlString = value as! URL
                    instructor.websites.append(urlString.absoluteString)
                }
            }
        }
        
        
        self.weeklyEditingVC!.tableView.beginUpdates()
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(instructor) //
        do {
            try realm.commitWrite()
        } catch let error {
            print(error.localizedDescription)
        }
        
        let instructorRowContent = ScheduleRowContent(identifier: "InstructorCell")
        instructorRowContent.instructor = instructor
        let dictCount = self.weeklyEditingVC!.dictionary[2]!.count
        if (self.weeklyEditingVC!.dictionary[2]?[dictCount - 1].identifier != "NewInstructorCell") {
            self.weeklyEditingVC!.dictionary[2]?.insert(instructorRowContent, at: dictCount - 2)
            self.weeklyEditingVC!.tableView.insertRows(at: [IndexPath(row: dictCount - 2, section: 2)], with: .none)
        } else {
            self.weeklyEditingVC!.dictionary[2]?.insert(instructorRowContent, at: dictCount - 1)
            self.weeklyEditingVC!.tableView.insertRows(at: [IndexPath(row: dictCount - 1, section: 2)], with: .none)
        }
        
        self.weeklyEditingVC!.tableView.endUpdates()
        
        self.weeklyEditingVC!.tableView.reloadData()
        
        self.navigationController?.popViewController()
    }
    
    func completeEditing()
    {
        guard self.course != nil else { return }
        let instructor = RLMInstructor()
        instructor.course = self.course
        instructor.type = self.type
        
        getInfo(instructor)
        
        getOfficeLocation(instructor)
        
        getOfficeHours(instructor)
        
        getValues(instructor)
        
        self.instructor?.edit(with: instructor, completion: { (editedInstructor) in
            print("Successfully Replaced Instructor")
            self.instructor = editedInstructor
            for (index, scheduleRowContent) in self.weeklyEditingVC!.dictionary[2]!.enumerated() {
                if (scheduleRowContent.instructor?.id == self.instructor?.id) {
                    self.weeklyEditingVC!.dictionary[2]![index].instructor = self.instructor //editedInstructor
                }
            }
            //self.instructor = editedInstructor
            
            //self.weeklyEditingVC!.tableView.reloadRows(at: [IndexPath(row: self.weeklyEditingVC!.instructors.index(of: self.instructor!)!, section: 2)], with: .none)
            
            self.weeklyEditingVC!.tableView.reloadData()
            self.navigationController?.popFade()
        })
    }
    
    @objc func doneWithEditing()
    {
        completeEditing()
        navigationController?.popViewController()
    }
    
    @objc func instructorNameDidChange(textField: UITextField)
    {
        if textField.text?.count ?? 0 > 0
        {
            navigationItem.title = textField.text!
        }
        else
        {
            navigationItem.title = (editingMode == .creating) ? "New Instructor" : "Instructor"
        }
    }
    
    @objc func pickInstructorImage(sender: UIButton) {
        let alert:UIAlertController = UIAlertController(title: nil,
                                                        message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default) { UIAlertAction in
            self.openGallery()
        }
        
        
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            // Called when user taps outside
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Image Pick Management
    
    func openCamera() {
        let picker = UIImagePickerController()
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self
            picker.allowsEditing = true
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
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
        
    }
}

extension InstructorEditingModeVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImage = image
            guard let infoRow = form.rowBy(tag: "InfoRow") as? InfoRow else { return }
            let cell = infoRow.cell
            cell?.instructorImageButton.setImage(image, for: .normal)
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
