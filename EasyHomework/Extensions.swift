//
//  Extensions.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-27.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class Extensions: NSObject {

}

//From http://stackoverflow.com/a/31311740/6051635
extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
            UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
            UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
            UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
}

extension String {
    
    func containsIgnoringCase(_ find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
}

/*extension UILabel {
    func setTextWithAppropriateStrikethrough(text: String) {
        if (self.attributedText.attributes)
        self.attributedText = NSAttributedString(string: self.text!, attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
    }
}*/

extension NSDate {
    
    func toReadableString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        let dateString = formatter.string(from: self as Date)
        return dateString
    }
    
    func toReadableTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.none
        formatter.timeStyle = DateFormatter.Style.short
        let dateString = formatter.string(from: self as Date)
        return dateString
    }
    
    func toRemainingDaysString() -> String {
        let cal = Calendar.current
        var components = cal.dateComponents([.era, .year, .month, .day], from: NSDate() as Date)
        let today = cal.date(from: components)
        let endDateComponents = cal.dateComponents([.era, .year, .month, .day], from: self as Date)
        let otherDate = cal.date(from: endDateComponents)
        
        components = cal.dateComponents([Calendar.Component.day], from: (today! as Date), to: otherDate!)
        if (components.day! == 0) {
            return "Due Today."
        }
        if (components.day! == 1) {
            return "Due Tomorrow."
        }
        if (components.day! >= 14) {
            let weeks = (components.day! / 7)
            return "Due in " + String(weeks) + " weeks."
        }
        if (components.day! == -1) {
            return "Due Yesterday."
        }
        var day = "day"
        if (components.day! > 1 || components.day! < -1) {
            day += "s"
        }
        if (components.day! < 0) {
            let stringAbsDay = String(abs(components.day!))
            return "Due " + stringAbsDay + " " + day + " ago."
        }
        return "Due in " + String(components.day!) + " " + day + "."
    }
    
    func numberOfDaysUntilDate() -> Int {
        let cal = Calendar.current
        var components = cal.dateComponents([.era, .year, .month, .day], from: NSDate() as Date)
        let today = cal.date(from: components)
        let endDateComponents = cal.dateComponents([.era, .year, .month, .day], from: self as Date)
        let otherDate = cal.date(from: endDateComponents)
        
        components = cal.dateComponents([Calendar.Component.day], from: (today! as Date), to: otherDate!)
        if (components.day == nil) { //shouldn't execute.
            print("components.day is nil!")
            return 0
        }
        return components.day!
    }
    
    func numberOfMinutesUntilDate() -> Int {
        let difference = self.timeIntervalSinceNow
        
        let minutes = Int(difference / 60)
        return Int(minutes)
    }
    
    func overTwoWeeksAway() -> Bool { //Also in Date extension
        if (self.numberOfDaysUntilDate() > 14) {
            return true
        } else {
            return false
        }
    }
    
    func afterToday() -> Bool {
        if (self.numberOfDaysUntilDate() >= 1) {
            return true
        } else {
            return false
        }
    }
    
    //If the task is Regular scope, this will return true if date is over two weeks away.
    //If the task is Event scope, this will return true if date is after today.
    func overScopeThreshold(task: RLMTask) -> Bool {
        if (task.scope == "Regular" && self.overTwoWeeksAway()) {
            return true
        }
        if (task.scope == "Event" && self.afterToday()) {
            return true
        }
        return false
    }
    
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self as Date).weekday
    }
    
}

extension Date {
    func numberOfDaysUntilDate() -> Int {
        let cal = Calendar.current
        var components = cal.dateComponents([.era, .year, .month, .day], from: NSDate() as Date)
        let today = cal.date(from: components)
        let endDateComponents = cal.dateComponents([.era, .year, .month, .day], from: self as Date)
        let otherDate = cal.date(from: endDateComponents)
        
        components = cal.dateComponents([Calendar.Component.day], from: (today! as Date), to: otherDate!)
        if (components.day == nil) { //shouldn't execute.
            print("components.day is nil!")
            return 0
        }
        return components.day!
    }
    
    func overTwoWeeksAway() -> Bool { //Also in NSDate extension
        if (self.numberOfDaysUntilDate() > 14) {
            return true
        } else {
            return false
        }
    }
    
    func afterToday() -> Bool {
        if (self.numberOfDaysUntilDate() >= 1) {
            return true
        } else {
            return false
        }
    }
    
    //If the task is Regular scope, this will return true if date is over two weeks away.
    //If the task is Event scope, this will return true if date is after today.
    func overScopeThreshold(task: RLMTask) -> Bool {
        if (task.scope == "Regular" && self.overTwoWeeksAway()) {
            return true
        }
        if (task.scope == "Event" && self.afterToday()) {
            return true
        }
        return false
    }
    
    var time: Time {
        return Time(self)
    }
    
    func isPast() -> Bool {
        if (self.time < Date().time) {
            return true
        } else {
            return false
        }
        /*if (self < Date()) {
            return true
        } else {
            return false
        }*/
    }
    
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    //Take (self) date with the proper time and put it on the correct date.
    func useSameDayAs(correctDate: Date) -> Date   {
        let cal = Calendar.current
        let priorComponents = cal.dateComponents([.weekday, .year, .month, .day, .hour, .minute, .second], from: self)
        var newComponents = cal.dateComponents([.weekday, .year, .month, .day, .hour, .minute, .second], from: correctDate)
        
        newComponents.second = priorComponents.second
        newComponents.minute = priorComponents.minute
        newComponents.hour = priorComponents.hour
        
        return cal.date(from: newComponents)!
    }
    
    //Take (self) date and make the time of it be 11:59:59PM. (Likely to ensure tasks without TimeSet are being sorted consistently.)
    func convertToLatestPossibleTimeOfDay() -> Date   {
        let cal = Calendar.current
        var components = cal.dateComponents([.weekday, .year, .month, .day, .hour, .minute, .second], from: self)
        
        components.second = 59
        components.minute = 59
        components.hour = 23
        
        return cal.date(from: components)!
    }
    
    //Take (self) date and make the time of it have 0 seconds, i.e.) 11:59:59 => 11:59:00
    func withoutExtraneousSeconds() -> Date   {
        let cal = Calendar.current
        var components = cal.dateComponents([.weekday, .year, .month, .day, .hour, .minute, .second], from: self)
        
        components.second = 0
        
        return cal.date(from: components)!
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self, wrappingComponents: false)!
    }
    
    var earliestTimeToday: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)! //Earliest possible date in the current day.
    }
    
    func numberOfDaysBetweenTwoDates(start: Date, end: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
}

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}

extension Results {
    func toArray() -> [Results.Iterator.Element] {
        return map { $0 }
    }
}

extension UINavigationBar {
    
    func setBottomBorderColor(color: UIColor, height: CGFloat) -> UIView {
        
        let bottomBorderView = UIView(frame: CGRect.zero)
        bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderView.backgroundColor = color
        
        self.addSubview(bottomBorderView)
        
        let views = ["border": bottomBorderView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[border]|", options: [], metrics: nil, views: views))
        self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
        self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: height))
        
        return bottomBorderView
    }
}
