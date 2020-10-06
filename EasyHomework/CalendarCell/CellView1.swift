//
//  CellView.swift
//  CalendarTutorial
//
//  Created by Jeron Thomas on 2016-10-15.
//  Copyright © 2016 OS-Tech. All rights reserved.
//
import UIKit
//import JTAppleCalendar

class CellView1: JTAppleCell {
    @IBOutlet var dayLabel: UILabel!
    
    @IBOutlet var moreLabel: UILabel!
    
    @IBOutlet var selectedView: UIView!
    @IBOutlet weak var vw: UIView!
    
    //Outlet for 1 circle
    @IBOutlet weak var view1bg: UIView!
    @IBOutlet weak var view1bg_circle1: UIView!

     //Outlet for 2 circle
    @IBOutlet weak var view2bg: UIView!
    @IBOutlet weak var view2bg_circle1: UIView!
    @IBOutlet weak var view2bg_circle2: UIView!

    
     //Outlet for 3 circle
    @IBOutlet weak var view3bg: UIView!
    @IBOutlet weak var view3bg_circle1: UIView!
    @IBOutlet weak var view3bg_circle2: UIView!
    @IBOutlet weak var view3bg_circle3: UIView!
    
     //Outlet for 4 circle
    @IBOutlet weak var view4bg: UIView!
    @IBOutlet weak var view4bg_circle1: UIView!
    @IBOutlet weak var view4bg_circle2: UIView!
    @IBOutlet weak var view4bg_circle3: UIView!
    @IBOutlet weak var view4bg_circle4: UIView!
    
     //Outlet for 5 circle
    @IBOutlet weak var view5bg: UIView!
    @IBOutlet weak var view5bg_circle1: UIView!
    @IBOutlet weak var view5bg_circle2: UIView!
    @IBOutlet weak var view5bg_circle3: UIView!
    @IBOutlet weak var view5bg_circle4: UIView!
    @IBOutlet weak var view5bg_circle5: UIView!

    @IBOutlet weak var bottomBorder: UIView!
//    let bottomBorder = UIView()

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet var cellBgView: UIView!

    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    func setupCellForState(state:CellState, withDate date:Date, andEvents arrayEvents:[Any]) {
        self.isHidden       = false
        self.dayLabel.text  = state.text
        self.setViews(date: state, eventsOfDate: arrayEvents)
        
        //Change for cellview
        self.selectedView.backgroundColor   = UIColor.clear
        self.dayLabel.textColor             = UIColor.white
        self.backgroundColor                = #colorLiteral(red: 0.1071848497, green: 0.1071884111, blue: 0.1071864888, alpha: 1) //affects color of borders of cells.
        self.bottomBorder.backgroundColor   = UIColor.unSelectedBorderColor()
        
        
        if (Calendar.current.isDateInToday(date)){
            self.selectedView.backgroundColor = UIColor(red: 80/255.0, green: 176/255.0, blue: 69/255.0, alpha: 1.0)
            self.dayLabel.textColor = UIColor.white
        }
        
        self.roundCorners()
        self.handleTextColorFor(cellState: state)
    }
    
    
    //set cell views according to the data model+
    func setViews(date: CellState, eventsOfDate:[Any]) {
        if eventsOfDate.count > 0 {
            switch eventsOfDate.count {
            case 1:
                
                self.view1bg.isHidden   = false
                self.view3bg.isHidden   = true
                self.view2bg.isHidden   = true
                self.view4bg.isHidden   = true
                self.view5bg.isHidden   = true
                self.moreLabel.isHidden = true
                
                if let task1 = eventsOfDate[0] as? RLMTask{
                    self.vw.backgroundColor = task1.course?.color?.getUIColorObjectWith(alpha: task1.completed ? 0.20 : 1.0)
                }else{
                   let task1 = eventsOfDate[0] as! RLMRepeatingSchedule
                    self.vw.backgroundColor = task1.course?.color?.getUIColorObjectWith(alpha:1.0)
                }
                
            case 2:
                
                self.view1bg.isHidden   = true
                self.view4bg.isHidden   = true
                self.view2bg.isHidden   = false
                self.view3bg.isHidden   = true
                self.view5bg.isHidden   = true
                self.moreLabel.isHidden = true
                
                if let task1 = eventsOfDate[0] as? RLMTask{
                    self.view2bg_circle1.backgroundColor = task1.course?.color?.getUIColorObjectWith(alpha: task1.completed ? 0.20 : 1.0)
                }else{
                    let task1 = eventsOfDate[0] as! RLMRepeatingSchedule
                    self.view2bg_circle1.backgroundColor = task1.course?.color?.getUIColorObjectWith(alpha:1.0)
                }
                
                if let task2 = eventsOfDate[1] as? RLMTask{
                    self.view2bg_circle2.backgroundColor = task2.course?.color?.getUIColorObjectWith(alpha: task2.completed ? 0.20 : 1.0)
                }else{
                    let task2 = eventsOfDate[1] as! RLMRepeatingSchedule
                    self.view2bg_circle2.backgroundColor = task2.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
                
                
            case 3:
                
                self.view1bg.isHidden   = true
                self.view4bg.isHidden   = true
                self.view2bg.isHidden   = true
                self.view5bg.isHidden   = true
                self.view3bg.isHidden   = false
                self.moreLabel.isHidden = true
                
                
                if let task1 = eventsOfDate[0] as? RLMTask{
                    self.view3bg_circle1.backgroundColor = task1.course?.color?.getUIColorObjectWith(alpha: task1.completed ? 0.20 : 1.0)
                }else{
                    let task1 = eventsOfDate[0] as! RLMRepeatingSchedule
                    self.view3bg_circle1.backgroundColor = task1.course?.color?.getUIColorObjectWith(alpha:1.0)
                }
                
                if let task2 = eventsOfDate[1] as? RLMTask{
                    self.view3bg_circle2.backgroundColor = task2.course?.color?.getUIColorObjectWith(alpha: task2.completed ? 0.20 : 1.0)
                }else{
                    let task2 = eventsOfDate[1] as! RLMRepeatingSchedule
                    self.view3bg_circle2.backgroundColor = task2.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
                
                if let task3 = eventsOfDate[2] as? RLMTask{
                    self.view3bg_circle3.backgroundColor = task3.course?.color?.getUIColorObjectWith(alpha: task3.completed ? 0.20 : 1.0)
                }else{
                    let task3 = eventsOfDate[2] as! RLMRepeatingSchedule
                    self.view3bg_circle3.backgroundColor = task3.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
                
            case 4:
                
                self.view1bg.isHidden   = true
                self.view4bg.isHidden   = false
                self.view2bg.isHidden   = true
                self.view3bg.isHidden   = true
                self.view5bg.isHidden   = true
                self.moreLabel.isHidden = true
  
                if let task1 = eventsOfDate[0] as? RLMTask{
                    self.view4bg_circle1.backgroundColor = task1.course?.color?.getUIColorObjectWith(alpha: task1.completed ? 0.20 : 1.0)
                }else{
                    let task1 = eventsOfDate[0] as! RLMRepeatingSchedule
                    self.view4bg_circle1.backgroundColor = task1.course?.color?.getUIColorObjectWith(alpha:1.0)
                }
                
                if let task2 = eventsOfDate[1] as? RLMTask{
                    self.view4bg_circle2.backgroundColor = task2.course?.color?.getUIColorObjectWith(alpha: task2.completed ? 0.20 : 1.0)
                }else{
                    let task2 = eventsOfDate[1] as! RLMRepeatingSchedule
                    self.view4bg_circle2.backgroundColor = task2.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
                
                if let task3 = eventsOfDate[2] as? RLMTask{
                    self.view4bg_circle3.backgroundColor = task3.course?.color?.getUIColorObjectWith(alpha: task3.completed ? 0.20 : 1.0)
                }else{
                    let task3 = eventsOfDate[2] as! RLMRepeatingSchedule
                    self.view4bg_circle3.backgroundColor = task3.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
                
                if let task4 = eventsOfDate[3] as? RLMTask{
                    self.view4bg_circle4.backgroundColor = task4.course?.color?.getUIColorObjectWith(alpha: task4.completed ? 0.20 : 1.0)
                }else{
                    let task4 = eventsOfDate[3] as! RLMRepeatingSchedule
                    self.view4bg_circle4.backgroundColor = task4.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
                
                
            case 5:
                
                self.view1bg.isHidden   = true
                self.view4bg.isHidden   = true
                self.view2bg.isHidden   = true
                self.view3bg.isHidden   = true
                self.view5bg.isHidden   = false
                self.moreLabel.isHidden = true
                
                if let task1 = eventsOfDate[0] as? RLMTask{
                    self.view5bg_circle1.backgroundColor = task1.course?.color?.getUIColorObjectWith(alpha: task1.completed ? 0.20 : 1.0)
                }else{
                    let task1 = eventsOfDate[0] as! RLMRepeatingSchedule
                    self.view5bg_circle1.backgroundColor = task1.course?.color?.getUIColorObjectWith(alpha:1.0)
                }
                
                if let task2 = eventsOfDate[1] as? RLMTask{
                    self.view5bg_circle2.backgroundColor = task2.course?.color?.getUIColorObjectWith(alpha: task2.completed ? 0.20 : 1.0)
                }else{
                    let task2 = eventsOfDate[1] as! RLMRepeatingSchedule
                    self.view5bg_circle2.backgroundColor = task2.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
                
                if let task3 = eventsOfDate[2] as? RLMTask{
                    self.view5bg_circle3.backgroundColor = task3.course?.color?.getUIColorObjectWith(alpha: task3.completed ? 0.20 : 1.0)
                }else{
                    let task3 = eventsOfDate[2] as! RLMRepeatingSchedule
                    self.view5bg_circle3.backgroundColor = task3.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
                
                if let task4 = eventsOfDate[3] as? RLMTask{
                    self.view5bg_circle4.backgroundColor = task4.course?.color?.getUIColorObjectWith(alpha: task4.completed ? 0.20 : 1.0)
                }else{
                    let task4 = eventsOfDate[3] as! RLMRepeatingSchedule
                    self.view5bg_circle4.backgroundColor = task4.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
                
                if let task5 = eventsOfDate[4] as? RLMTask{
                    self.view5bg_circle5.backgroundColor = task5.course?.color?.getUIColorObjectWith(alpha: task5.completed ? 0.20 : 1.0)
                }else{
                    let task5 = eventsOfDate[4] as! RLMRepeatingSchedule
                    self.view5bg_circle5.backgroundColor = task5.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }


            default:
                
                
                self.view1bg.isHidden   = true
                self.view4bg.isHidden   = true
                self.view2bg.isHidden   = true
                self.view3bg.isHidden   = true
                self.view5bg.isHidden   = false
                self.moreLabel.isHidden = false
                
                if let task1 = eventsOfDate[0] as? RLMTask{
                    self.view5bg_circle1.backgroundColor = task1.course?.color?.getUIColorObjectWith(alpha: task1.completed ? 0.20 : 1.0)
                }else{
                    let task1 = eventsOfDate[0] as! RLMRepeatingSchedule
                    self.view5bg_circle1.backgroundColor = task1.course?.color?.getUIColorObjectWith(alpha:1.0)
                }
                
                if let task2 = eventsOfDate[1] as? RLMTask{
                    self.view5bg_circle2.backgroundColor = task2.course?.color?.getUIColorObjectWith(alpha: task2.completed ? 0.20 : 1.0)
                }else{
                    let task2 = eventsOfDate[1] as! RLMRepeatingSchedule
                    self.view5bg_circle2.backgroundColor = task2.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
                
                if let task3 = eventsOfDate[2] as? RLMTask{
                    self.view5bg_circle3.backgroundColor = task3.course?.color?.getUIColorObjectWith(alpha: task3.completed ? 0.20 : 1.0)
                }else{
                    let task3 = eventsOfDate[2] as! RLMRepeatingSchedule
                    self.view5bg_circle3.backgroundColor = task3.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
                
                if let task4 = eventsOfDate[3] as? RLMTask{
                    self.view5bg_circle4.backgroundColor = task4.course?.color?.getUIColorObjectWith(alpha: task4.completed ? 0.20 : 1.0)
                }else{
                    let task4 = eventsOfDate[3] as! RLMRepeatingSchedule
                    self.view5bg_circle4.backgroundColor = task4.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
                
                if let task5 = eventsOfDate[4] as? RLMTask{
                    self.view5bg_circle5.backgroundColor = task5.course?.color?.getUIColorObjectWith(alpha: task5.completed ? 0.20 : 1.0)
                }else{
                    let task5 = eventsOfDate[4] as! RLMRepeatingSchedule
                    self.view5bg_circle5.backgroundColor = task5.course?.color?.getUIColorObjectWith(alpha: 1.0)
                }
            }
        }else{
            self.view1bg.isHidden   = true
            self.view4bg.isHidden   = true
            self.view2bg.isHidden   = true
            self.view3bg.isHidden   = true
            self.view5bg.isHidden   = true
            
            self.moreLabel.isHidden = true
        }
    }
    
    func handleTextColorFor(cellState: CellState) {
        if cellState.isSelected {
            if cellState.dateBelongsTo == .thisMonth {
                self.dayLabel.textColor = UIColor.white
                self.selectedView.backgroundColor = UIColor.clear
                self.cellBgView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
                self.bottomBorder.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                if (Calendar.current.isDateInToday(cellState.date)) {
                    self.selectedView.backgroundColor = UIColor(red: 80/255.0, green: 176/255.0, blue: 69/255.0, alpha: 1.0)
                }
            }else{
                self.isHidden = true
                self.dayLabel.textColor = UIColor.white
                self.selectedView.backgroundColor = UIColor.clear
                self.cellBgView.backgroundColor = #colorLiteral(red: 0.08235294118, green: 0.08235294118, blue: 0.08235294118, alpha: 1)
                self.bottomBorder.backgroundColor = UIColor.unSelectedBorderColor()
            }
        }else{
            self.bottomBorder.backgroundColor = UIColor.unSelectedBorderColor()
            if cellState.dateBelongsTo == .thisMonth {
                self.dayLabel.textColor = UIColor.white
                self.cellBgView.backgroundColor = #colorLiteral(red: 0.1071848497, green: 0.1071884111, blue: 0.1071864888, alpha: 1)
            }else{
                self.isHidden = true
                self.dayLabel.textColor = UIColor.clear
            }
        }
        
        if (cellState.day == .saturday || cellState.day == .sunday) {
            if (Calendar.current.isDateInToday(cellState.date)) {
                self.dayLabel.textColor = UIColor.white
            }else{
                self.dayLabel.textColor = #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
                if (cellState.isSelected) {
                    self.dayLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                }
            }
            
        }
    }
    
    func roundCorners() {
        let when = DispatchTime.now() + 0.1 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // view for 1 circle
            self.vw.layer.cornerRadius = self.vw.frame.size.height/2
            self.vw.clipsToBounds = true
            
            // view for 2 circle
            self.view2bg_circle1.layer.cornerRadius = self.view2bg_circle1.frame.size.height/2
            self.view2bg_circle1.clipsToBounds = true
            self.view2bg_circle2.layer.cornerRadius = self.view2bg_circle1.frame.size.height/2
            self.view2bg_circle2.clipsToBounds = true
            
            // view for 3 circle
            self.view3bg_circle1.layer.cornerRadius = self.view3bg_circle1.frame.size.height/2
            self.view3bg_circle1.clipsToBounds = true
            self.view3bg_circle2.layer.cornerRadius = self.view3bg_circle2.frame.size.height/2
            self.view3bg_circle2.clipsToBounds = true
            self.view3bg_circle3.layer.cornerRadius = self.view3bg_circle3.frame.size.height/2
            self.view3bg_circle3.clipsToBounds = true
            
            // view for 4 circle
            self.view4bg_circle1.layer.cornerRadius = self.view4bg_circle1.frame.size.height/2
            self.view4bg_circle1.clipsToBounds = true
            self.view4bg_circle2.layer.cornerRadius = self.view4bg_circle2.frame.size.height/2
            self.view4bg_circle2.clipsToBounds = true
            self.view4bg_circle3.layer.cornerRadius = self.view4bg_circle3.frame.size.height/2
            self.view4bg_circle3.clipsToBounds = true
            self.view4bg_circle4.layer.cornerRadius = self.view4bg_circle4.frame.size.height/2
            self.view4bg_circle4.clipsToBounds = true
            
            // view for 5 circle
            self.view5bg_circle1.layer.cornerRadius = self.view4bg_circle1.frame.size.height/2
            self.view5bg_circle1.clipsToBounds = true
            self.view5bg_circle2.layer.cornerRadius = self.view4bg_circle2.frame.size.height/2
            self.view5bg_circle2.clipsToBounds = true
            self.view5bg_circle3.layer.cornerRadius = self.view4bg_circle3.frame.size.height/2
            self.view5bg_circle3.clipsToBounds = true
            self.view5bg_circle4.layer.cornerRadius = self.view4bg_circle4.frame.size.height/2
            self.view5bg_circle4.clipsToBounds = true
            self.view5bg_circle5.layer.cornerRadius = self.view4bg_circle4.frame.size.height/2
            self.view5bg_circle5.clipsToBounds = true
            
        }
    }
    
    func handleSelectionFor(cellState: CellState) {
        if cellState.isSelected {
            self.cellBgView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
            self.bottomBorder.backgroundColor = UIColor.white
        }else{
            self.cellBgView.backgroundColor = UIColor.clear
            self.bottomBorder.backgroundColor = UIColor.unSelectedBorderColor()
        }
    }
}





@IBDesignable class RoundRectView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0
    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var borderWidth: CGFloat = 0.5
    private var customBackgroundColor = UIColor.white
    override var backgroundColor: UIColor?{
        didSet {
            customBackgroundColor = backgroundColor!
            super.backgroundColor = UIColor.clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     
    }
    
    override func draw(_ rect: CGRect) {
        customBackgroundColor.setFill()
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius ).fill()
        
        let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius - borderWidth/2)
        borderColor.setStroke()
        borderPath.lineWidth = borderWidth
        borderPath.stroke()
        
    }
}
