//
//  CalendarComponentVM.swift
//  Timetable
//
//  Created by Valentina Henao on 8/25/17.
//  Copyright © 2017 Valentina Henao. All rights reserved.
//

import UIKit
import Foundation

var slotColors = [UIColor(rgba: "#238E3B"), //Green
    UIColor(rgba: "#9F191E"), //Red
    UIColor(rgba: "#9F4114"), //Orange
    UIColor(rgba: "#1E5495"), //Blue
    UIColor(rgba: "#AD8310"), //Yellow
]

let TTColorGray = UIColor(rgba: "#B9B9B9")
let TTColorTodayColumn = UIColor(rgba: "#272727")
let TTColorMateBlack = UIColor(rgba: "#1C1C1C")

var rowHeight: CGFloat = 34

class CalendarComponentVM: NSObject {

//Array with String of Hours for Column 0
    
    let hoursInDay : [String] = {
        var hours = ["12AM", ""]
        var counter = 1
        for i in 1..<47 {
            if (i % 2 == 0) {
                hours.append("")
            } else {
                if counter < 12 {
                    hours.append(String(format: "%2dAM", counter))
                } else if counter == 12 {
                    hours.append(String(format: "%2dPM", counter))
                } else {
                    hours.append(String(format: "%2dPM", counter-12))
                }
                counter += 1
            }
        }
        return hours
    }()
    
    //Generates String with Formated Time Interval e.g 9:30-10PM

    func generateStringTime(start: Date, end: Date)-> String {
        
        var eventHours = String()
        //start
        if formattedTime(format: "HH", time: start) > 12 {
            eventHours = String(format: "%d", formattedTime(format: "HH", time: start)-12)
        } else {
            eventHours = String(format: "%d", formattedTime(format: "HH", time: start))
        }
        if extraRow(date: start) == 1 {
            eventHours.append(String(format: ":%d", (extraRow(date: start)*30)))
        }
        //end
        if formattedTime(format: "HH", time: end) > 12 {
            eventHours.append(String(format: "-%d", formattedTime(format: "HH", time: end)-12))
        } else {
            eventHours.append(String(format: "-%d", formattedTime(format: "HH", time: end)))
        }
        if extraRow(date: end) == 1 {
            eventHours.append(String(format: ":%d", (extraRow(date: end)*30)))
        }
        //AM or PM
        if formattedTime(format: "HH", time: end) >= 12 {
            eventHours.append("PM")
        } else {
            eventHours.append("AM")
        }
        
        return eventHours
    }
    
    //Return requested Date component value as Int
    
    func formattedTime(format: String, time: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return Int(dateFormatter.string(from: time))!
    }
    
    //Wether the event goes halfway through the hour or not, e.g: 4:30
    
    func extraRow(date: Date) -> Int {
        let minutes = self.formattedTime(format: "mm", time: date)
        if minutes < 30 {
            return 0
        } else {
            return 1
        }
    }
    
    func getDateFromIndex(index: IndexPath) -> Date {
        let calendar        = Calendar.current
        var dateComponents  = DateComponents()
        dateComponents.year = calendar.component(.year, from: Date())
        dateComponents.weekOfYear = calendar.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))
        dateComponents.weekday = index.column+1
        dateComponents.hour = index.row/2
        
        if index.row % 2 == 0 {
            dateComponents.minute = 29
        } else {
            dateComponents.minute = 59
        }
        
        let resultDate = calendar.date(from: dateComponents)
        
        return resultDate!
        
    }
    
    func getTimeOnlyFromDate(date: Date) -> Date {
        var calendar        = Calendar.current
        calendar.timeZone   = TimeZone.init(secondsFromGMT: 0)!
        let hour            = calendar.component(.hour, from: date)
        let minutes         = calendar.component(.minute, from: date)
        let seconds         = calendar.component(.second, from: date)
        
        var components      = DateComponents.init()
        components.hour     = hour
        components.minute   = minutes
        components.second   = seconds
        
        let finalDate = calendar.date(from: components)
        
        return finalDate!
        
    }
    
}
