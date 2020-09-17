//
//  CellCustomizer.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2018-02-05.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

class CellCustomizer: NSObject {

    //Not for use in CellForRow(..) because it uses animations.
    //This method should never use task.dueDate, and it should use the date property being passed to it instead.
    class func customizeHWCellAppearanceBasedOnDate(date: Date?, task: RLMTask, cell: HomeworkTableViewCell?, taskManager: UIViewController?) {
        if (task.course == nil) {
            cell?.colorView.color = UIColor.darkGray
            cell?.courseLabel.text = "N/A"
            cell?.homeworkImageView.image = UIImage(named: task.type + String(0))
        } else {
            cell?.homeworkImageView.image = UIImage(named: task.type + String(task.course!.colorStaticValue))
            //cell.colorView.color = UIColor(red: 43/255, green: 132/255, blue: 210/255, alpha: 1.0)
            cell?.colorView.color = task.course?.color?.getUIColorObject()
            if (task.course?.courseCode != nil) {
                cell?.courseLabel.text = task.course?.courseCode
            } else {
                cell?.courseLabel.text = task.course?.courseName
            }
            if (task.course?.facultyName != nil) {
                cell?.facultyImageView.image = UIImage(named: task.course!.facultyName!)
            }
        }
        //Below line commented on March 3rd, since it kept causing cells to look selected.
        ///cell?.cardView.backgroundColor = UIColor(colorLiteralRed: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
        if (date == nil) {
            if (task.type == "Assignment") {
                cell?.dueDateLabel.attributedText = NSAttributedString(string: "No due date.", attributes: cell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                cell?.dateLabel.attributedText = NSAttributedString(string: "Due anytime.", attributes: cell?.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
            } else {
                cell?.dueDateLabel.attributedText = NSAttributedString(string: "No date.", attributes: cell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                cell?.dateLabel.attributedText = NSAttributedString(string: "Happens anytime.", attributes: cell?.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
            }
            if (taskManager is HomeworkViewController) {
                UIView.animate(withDuration: 0.5, animations: { cell?.cardView.alpha = 1.0 })
            }
            return
        } else {
            cell?.dateLabel.attributedText = NSAttributedString(string: (date as! NSDate).toReadableString(), attributes: cell?.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
            if (task.type == "Assignment") {
                let numberOfDaysUntilDate = date!.numberOfDaysUntilDate()
                cell?.dueDateLabel.attributedText = NSAttributedString(string: (date as! NSDate).toRemainingDaysString(), attributes: cell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                if (task.dueDate != nil) {
                    if (numberOfDaysUntilDate == 0 && task.type == "Assignment" && (task.dueDate! as Date).isPast() && task.timeSet == true) {
                        cell?.dueDateLabel.attributedText = NSAttributedString(string: "Was Due Today.", attributes: cell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                    }
                }
            } else {
                var remainingDaysString = (date as! NSDate).toRemainingDaysString()
                remainingDaysString.remove(at: remainingDaysString.startIndex)
                remainingDaysString.remove(at: remainingDaysString.startIndex)
                remainingDaysString.remove(at: remainingDaysString.startIndex)
                //cell?.dueDateLabel.attributedText = NSAttributedString(string: "Scheduled" + remainingDaysString, attributes: cell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                let numberOfDaysUntilDate = date?.numberOfDaysUntilDate()
                if (date != nil) {
                    if (numberOfDaysUntilDate == 0 || numberOfDaysUntilDate == 1 || numberOfDaysUntilDate == -1) {
                        remainingDaysString.remove(at: remainingDaysString.startIndex)
                        cell?.dueDateLabel.attributedText = NSAttributedString(string: remainingDaysString, attributes: cell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                    } else if (numberOfDaysUntilDate! > 1) {
                        cell?.dueDateLabel.attributedText = NSAttributedString(string: "Occurs" + remainingDaysString, attributes: cell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                    } else if (numberOfDaysUntilDate! < -1) {
                        cell?.dueDateLabel.attributedText = NSAttributedString(string: "Was" + remainingDaysString, attributes: cell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                    }
                }
                if (task.timeSet == true && date != nil) {
                    //let numberOfDaysUntilDate = date?.numberOfDaysUntilDate()
                    let timeString = DateFormatter.localizedString(from: date as! Date, dateStyle: .none, timeStyle: .short)
                    remainingDaysString = remainingDaysString.substring(to: remainingDaysString.index(before: remainingDaysString.endIndex))
                    remainingDaysString += (" at " + timeString + ".")
                    if (numberOfDaysUntilDate == 0 || numberOfDaysUntilDate == 1 || numberOfDaysUntilDate == -1) {
                        //remainingDaysString.remove(at: remainingDaysString.startIndex)
                        if (numberOfDaysUntilDate == 0 && (date as! Date).isPast()) {
                            remainingDaysString.removeSubrange(remainingDaysString.startIndex ..< remainingDaysString.index(remainingDaysString.startIndex, offsetBy: 5))
                            remainingDaysString = "Was" + remainingDaysString
                            if (task.endDateAndTime != nil) {
                                if ((task.endDateAndTime! as Date).isPast() == false) {
                                    remainingDaysString.removeSubrange(remainingDaysString.startIndex ..< remainingDaysString.index(remainingDaysString.startIndex, offsetBy: 3))
                                    remainingDaysString = "Started" + remainingDaysString
                                }
                            }
                        }
                        cell?.dueDateLabel.attributedText = NSAttributedString(string: remainingDaysString, attributes: cell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                    } else if (numberOfDaysUntilDate != nil) {
                        if (numberOfDaysUntilDate! > 1) {
                            remainingDaysString.remove(at: remainingDaysString.startIndex)
                            remainingDaysString.remove(at: remainingDaysString.startIndex)
                            remainingDaysString.remove(at: remainingDaysString.startIndex)
                            cell?.dueDateLabel.attributedText = NSAttributedString(string: "In" + remainingDaysString, attributes: cell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                        } else if (numberOfDaysUntilDate! < -1) {
                            cell?.dueDateLabel.attributedText = NSAttributedString(string: "Was" + remainingDaysString, attributes: cell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                        }
                    }
                }
            }
            
            cell!.dateLabel.font = UIFont.systemFont(ofSize: cell!.dateLabel.font.pointSize)
            if (cell != nil && task.timeSet == true) {
            //let now = Date()
            let taskStartHour = Calendar.current.component(.hour, from: date! as Date)
            let numberOfDaysUntilDate = date!.numberOfDaysUntilDate()
            if (taskStartHour >= 0 && taskStartHour < 12 && numberOfDaysUntilDate == 0) {
                cell?.dateLabel.font = UIFont.italicSystemFont(ofSize: cell!.dateLabel.font.pointSize)
                cell?.dateLabel.attributedText = NSAttributedString(string: "This Morning.", attributes: cell?.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
            }
            if (taskStartHour >= 12 && taskStartHour < 16 && numberOfDaysUntilDate == 0) {
                cell?.dateLabel.font = UIFont.italicSystemFont(ofSize: cell!.dateLabel.font.pointSize)
                cell?.dateLabel.attributedText = NSAttributedString(string: "This Afternoon.", attributes: cell?.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
            }
            if (taskStartHour >= 16 && numberOfDaysUntilDate == 0) { //&& taskStartHour < 20
                cell?.dateLabel.font = UIFont.italicSystemFont(ofSize: cell!.dateLabel.font.pointSize)
                cell?.dateLabel.attributedText = NSAttributedString(string: "This Evening.", attributes: cell?.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
            }
            if (task.type == "Quiz" || task.type == "Midterm" || task.type == "Final" || task.scope == "Event") { //if this line changes, look at UpdateDateLabels in HWVC.
                let numberOfMinutesUntilDueDate = (date! as NSDate).numberOfMinutesUntilDate()
                let numberOfSecondsUntilDueDate = numberOfMinutesUntilDueDate * 60 //if this line changes, look at UpdateDateLabels in HWVC.
                //if (numberOfMinutesUntilDueDate <= 60 && numberOfMinutesUntilDueDate > 0) { //if this line changes, look at UpdateDateLabels in HWVC.
                if (numberOfSecondsUntilDueDate <= 3600 && numberOfSecondsUntilDueDate > 0) {
                    //cell.dateLabel.attributedText = NSAttributedString(string: "Starting Soon..", attributes: cell.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                    cell?.dateLabel.font = UIFont.italicSystemFont(ofSize: cell!.dateLabel.font.pointSize)
                    cell?.dateLabel.attributedText = NSAttributedString(string: "Starting Soon..", attributes: cell?.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                }
                if let numberOfMinutesUntilEndTime = task.endDateAndTime?.numberOfMinutesUntilDate() {
                    print(task.dueDate!.description)
                    print(task.endDateAndTime!.description)
                    let numberOfSecondsUntilEndTime = numberOfMinutesUntilEndTime * 60
                    //if (numberOfMinutesUntilDueDate <= 0 && numberOfMinutesUntilEndTime >= 0) {
                    if (numberOfSecondsUntilDueDate <= 0 && numberOfSecondsUntilEndTime >= 0) {
                        cell?.dateLabel.font = UIFont.italicSystemFont(ofSize: cell!.dateLabel.font.pointSize)
                        cell?.dateLabel.attributedText = NSAttributedString(string: "In-Progress..", attributes: cell?.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                    }
                    //if (numberOfMinutesUntilEndTime < 0 && numberOfMinutesUntilEndTime >= -60) {
                    if (numberOfSecondsUntilEndTime < 0 && numberOfSecondsUntilEndTime >= -3600) {
                        cell?.dateLabel.font = UIFont.italicSystemFont(ofSize: cell!.dateLabel.font.pointSize)
                        cell?.dateLabel.attributedText = NSAttributedString(string: "Recently Finished.", attributes: cell?.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                    }
                }
            //print("Minutes Until Task " + task.name + " : " + numberOfMinutesUntilDueDate.description)
            }
            }
        }
        
        if (date != nil) {
            if (date!.overScopeThreshold(task: task) && taskManager is HomeworkViewController) {
                UIView.animate(withDuration: 0.5, animations: { cell?.cardView.alpha = 0.7 })
            } else {
                UIView.animate(withDuration: 0.5, animations: { cell?.cardView.alpha = 1.0 })
            }
        }
    }
    
    class func cellForRowCustomization(task: RLMTask, cell: HomeworkTableViewCell, taskManager: UIViewController?) {
        
        let FADED_BLACK_COLOR = UIColor(red: 103/255, green: 103/255, blue: 103/255, alpha: 1.0)
        cell.titleLabel.text = task.name
        if (task.course == nil) {
            cell.colorView.color = UIColor.darkGray
            cell.courseLabel.text = "N/A"
            cell.homeworkImageView.image = UIImage(named: task.type + String(0))
        } else {
            cell.homeworkImageView.image = UIImage(named: task.type + String(task.course!.colorStaticValue))
            //cell.colorView.color = UIColor(red: 43/255, green: 132/255, blue: 210/255, alpha: 1.0)
            cell.colorView.color = task.course?.color?.getUIColorObject()
            if (task.course?.courseCode != nil) {
                cell.courseLabel.text = task.course?.courseCode
            } else {
                cell.courseLabel.text = task.course?.courseName
            }
            if (task.course?.facultyName != nil) {
                cell.facultyImageView.image = UIImage(named: task.course!.facultyName!)
            }
        }
        if (task.dueDate == nil) {
            if (task.type == "Assignment") {
                cell.dueDateLabel.text = "No due date."
                cell.dateLabel.text = "Due anytime."
            } else {
                cell.dueDateLabel.text = "No date."
                cell.dateLabel.text = "Happens anytime."
            }
        } else {
            if (task.type == "Assignment") {
                let numberOfDaysUntilDate = task.dueDate!.numberOfDaysUntilDate()
                cell.dueDateLabel.text = task.dueDate!.toRemainingDaysString()
                if (numberOfDaysUntilDate == 0 && task.type == "Assignment" && (task.dueDate! as Date).isPast() && task.timeSet == true) {
                    cell.dueDateLabel.text = "Was Due Today."
                }
            } else {
                var remainingDaysString = task.dueDate!.toRemainingDaysString()
                remainingDaysString.remove(at: remainingDaysString.startIndex)
                remainingDaysString.remove(at: remainingDaysString.startIndex)
                remainingDaysString.remove(at: remainingDaysString.startIndex)
                let numberOfDaysUntilDate = task.dueDate!.numberOfDaysUntilDate()
                if (numberOfDaysUntilDate == 0 || numberOfDaysUntilDate == 1 || numberOfDaysUntilDate == -1) {
                    remainingDaysString.remove(at: remainingDaysString.startIndex)
                    cell.dueDateLabel.text = remainingDaysString
                } else if (numberOfDaysUntilDate > 1) {
                    cell.dueDateLabel.text = "Occurs" + remainingDaysString
                } else if (numberOfDaysUntilDate < -1) {
                    cell.dueDateLabel.text = "Was" + remainingDaysString
                }
                if (task.timeSet == true && task.dueDate != nil) {
                    let timeString = DateFormatter.localizedString(from: task.dueDate! as Date, dateStyle: .none, timeStyle: .short)
                    remainingDaysString = remainingDaysString.substring(to: remainingDaysString.index(before: remainingDaysString.endIndex))
                    remainingDaysString += (" at " + timeString + ".")
                    if (numberOfDaysUntilDate == 0 || numberOfDaysUntilDate == 1 || numberOfDaysUntilDate == -1) {
                        //remainingDaysString.remove(at: remainingDaysString.startIndex)
                        if (numberOfDaysUntilDate == 0 && (task.dueDate as! Date).isPast()) {
                            remainingDaysString.removeSubrange(remainingDaysString.startIndex ..< remainingDaysString.index(remainingDaysString.startIndex, offsetBy: 5))
                            remainingDaysString = "Was" + remainingDaysString
                            if (task.endDateAndTime != nil) {
                                if ((task.endDateAndTime! as Date).isPast() == false) {
                                    remainingDaysString.removeSubrange(remainingDaysString.startIndex ..< remainingDaysString.index(remainingDaysString.startIndex, offsetBy: 3))
                                    remainingDaysString = "Started" + remainingDaysString
                                }
                            }
                        }
                        cell.dueDateLabel.text = remainingDaysString
                    } else {
                        if (numberOfDaysUntilDate > 1) {
                            remainingDaysString.remove(at: remainingDaysString.startIndex)
                            remainingDaysString.remove(at: remainingDaysString.startIndex)
                            remainingDaysString.remove(at: remainingDaysString.startIndex)
                            cell.dueDateLabel.attributedText = NSAttributedString(string: "In" + remainingDaysString, attributes: cell.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                        } else if (numberOfDaysUntilDate < -1) {
                            cell.dueDateLabel.attributedText = NSAttributedString(string: "Was" + remainingDaysString, attributes: cell.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                        }
                    }
                }
            }
            cell.dateLabel.font = UIFont.systemFont(ofSize: cell.dateLabel.font.pointSize)
            cell.dateLabel.text = task.dueDate!.toReadableString()

            if (task.timeSet == true) {
            //let now = Date()
            let taskStartHour = Calendar.current.component(.hour, from: task.dueDate! as Date)
            let numberOfDaysUntilDate = task.dueDate!.numberOfDaysUntilDate()
            if (taskStartHour >= 0 && taskStartHour < 12 && numberOfDaysUntilDate == 0) {
                cell.dateLabel.font = UIFont.italicSystemFont(ofSize: cell.dateLabel.font.pointSize)
                cell.dateLabel.text = "This Morning."
            }
            if (taskStartHour >= 12 && taskStartHour < 16 && numberOfDaysUntilDate == 0) {
                cell.dateLabel.font = UIFont.italicSystemFont(ofSize: cell.dateLabel.font.pointSize)
                cell.dateLabel.text = "This Afternoon."
            }
            if (taskStartHour >= 16 && numberOfDaysUntilDate == 0) { //&& taskStartHour < 20
                cell.dateLabel.font = UIFont.italicSystemFont(ofSize: cell.dateLabel.font.pointSize)
                cell.dateLabel.text = "This Evening."
            }
            if (task.type == "Quiz" || task.type == "Midterm" || task.type == "Final" || task.scope == "Event") {
            let numberOfMinutesUntilDueDate = task.dueDate!.numberOfMinutesUntilDate()
            let numberOfSecondsUntilDueDate = numberOfMinutesUntilDueDate * 60
            //if (numberOfMinutesUntilDueDate <= 60 && numberOfMinutesUntilDueDate > 0) { //if this line changes, look at UpdateDateLabels in HWVC.
            if (numberOfSecondsUntilDueDate <= 3600 && numberOfSecondsUntilDueDate > 0) {
                //cell.dateLabel.attributedText = NSAttributedString(string: "Starting Soon..", attributes: cell.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                cell.dateLabel.font = UIFont.italicSystemFont(ofSize: cell.dateLabel.font.pointSize)
                cell.dateLabel.text = "Starting Soon.."
            }
            if let numberOfMinutesUntilEndTime = task.endDateAndTime?.numberOfMinutesUntilDate() {
                let numberOfSecondsUntilEndTime = numberOfMinutesUntilEndTime * 60
                //if (numberOfMinutesUntilDueDate <= 0 && numberOfMinutesUntilEndTime >= 0) {
                if (numberOfSecondsUntilDueDate <= 0 && numberOfSecondsUntilEndTime >= 0) {
                    cell.dateLabel.font = UIFont.italicSystemFont(ofSize: cell.dateLabel.font.pointSize)
                    cell.dateLabel.text = "In-Progress.."
                }
                //if (numberOfMinutesUntilEndTime < 0 && numberOfMinutesUntilEndTime >= -60) {
                if (numberOfSecondsUntilEndTime < 0 && numberOfSecondsUntilEndTime >= -3600) {
                    cell.dateLabel.font = UIFont.italicSystemFont(ofSize: cell.dateLabel.font.pointSize)
                    cell.dateLabel.text = "Recently Finished."
                }
            }
            }
            }
            //print("Minutes Until Task " + task.name + " : " + numberOfMinutesUntilDueDate.description)
            
            if (task.dueDate!.overScopeThreshold(task: task) && taskManager is HomeworkViewController) {
                cell.cardView.alpha = 0.7
            } else {
                cell.cardView.alpha = 1.0
            }
        }
        //prepareForReuse(..) implemented in Cell Custom Subclass to reset cell state.
        if (task.completed) {
            cell.leadingCompletionConstraint.constant = 32
            cell.bringSubview(toFront: cell.completionImageView)
            CellCustomizer.strikeThroughLabel(cell.titleLabel)
            CellCustomizer.strikeThroughLabel(cell.courseLabel)
            CellCustomizer.strikeThroughLabel(cell.dueDateLabel)
            CellCustomizer.strikeThroughLabel(cell.dateLabel)
            cell.titleLabel.textColor = FADED_BLACK_COLOR
            cell.courseLabel.textColor = FADED_BLACK_COLOR
            cell.dueDateLabel.textColor = FADED_BLACK_COLOR
            cell.dateLabel.textColor = FADED_BLACK_COLOR
            cell.completionImageView.layer.shadowRadius = 0.5
            cell.completionImageView.layer.shadowOpacity = 1.0
            cell.completionImageView.image = #imageLiteral(resourceName: "Green Checkmark")
            cell.repeatsImageView.image = #imageLiteral(resourceName: "Grey Repeats")
        }
        
        if (task.repeatingSchedule == nil) {
            cell.repeatsImageView.isHidden = true
        } else {
            cell.repeatsImageView.isHidden = false
        }
    }
    
    class func strikeThroughLabel(_ label: UILabel?) {
        if (label == nil) { return }
        let attributedString = NSMutableAttributedString(string: label!.text!, attributes: [NSAttributedStringKey.strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue])
        attributedString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: NSMakeRange(0, attributedString.length))
        label!.attributedText = attributedString
    }
    
    class func unstrikeThroughLabel(_ label: UILabel?) {
        if (label == nil) { return }
        let attributedString = NSAttributedString(string: label!.text!, attributes: [:])
        label!.attributedText = attributedString
    }
    
}
