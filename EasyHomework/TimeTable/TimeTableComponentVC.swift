//
//  CalendarComponentVC.swift
//  Timetable
//
//  Created by Valentina Henao on 8/23/17.
//  Copyright © 2017 Valentina Henao. All rights reserved.
//

import UIKit
import SpreadsheetView
import RealmSwift


class TimeTableComponentVC: B4GradViewController, SlotNavigationDelegate, SpreadsheetViewDataSource, SpreadsheetViewDelegate, UIScrollViewDelegate, UISplitViewControllerDelegate {
    
    var spreadsheetView = SpreadsheetView()
    
    var colors = [String: UIColor]()
    
    var mergedCells = [CellRange]()
    var selectedCell:SlotCell? = nil
    
    var eventsCurrentWeek = [RLMRepeatingSchedule]() {
        didSet {
            var colorIndex = 0
            for event in eventsCurrentWeek {
                if colors[event.course!.courseName] == nil {
                    if !slotColors.indices.contains(colorIndex) {
                        colors[event.course!.courseName ] = UIColor.gray
                    } else {
                        colors[event.course!.courseName ] = slotColors[colorIndex]
                    }
                colorIndex += 1
                }
            }
        }
    }
    
    var circle = UIView()
    var line = UIView()
    var circleSub = UIView()
    
    var columnWidth: CGFloat = 0
    let hairline = 1 / UIScreen.main.scale
    
    var viewModel = CalendarComponentVM()
    
    var scrollOffset = Int(rowHeight)*15 + 6
    
    var didLoad = false

    override func viewWillLayoutSubviews() {
        //spreadsheetView.frame = self.view.frame //for testing purposes
        spreadsheetView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            spreadsheetView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            spreadsheetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            spreadsheetView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
            spreadsheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            spreadsheetView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            spreadsheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        spreadsheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        configureTimeIndicator()
        self.backgroundView.frame = self.view.frame
        
        //Weekday views at the top.
        let topX = CGFloat(41.0)
        let topY = self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.height
        
        columnWidth = (self.view.frame.size.width - (40 + ( hairline * 9))) / 5 //This needs to occur before the visual layout modifications below.
        
        self.weekdayCells[0].frame = CGRect(x: topX, y: topY, width: self.columnWidth+1, height: 35)
        self.weekdayCells[1].frame = CGRect(x: topX+1+(self.columnWidth), y: topY, width: self.columnWidth+1, height: 35)
        self.weekdayCells[2].frame = CGRect(x: topX+1+(self.columnWidth)*2, y: topY, width: self.columnWidth+1, height: 35)
        self.weekdayCells[3].frame = CGRect(x: topX+1+(self.columnWidth)*3, y: topY, width: self.columnWidth+1, height: 35)
        self.weekdayCells[4].frame = CGRect(x: topX+1+(self.columnWidth)*4, y: topY, width: self.columnWidth+3, height: 35)
        for weekdayCell in self.weekdayCells {
            self.view.bringSubview(toFront: weekdayCell)
            weekdayCell.blackLine.frame = CGRect(x: 0, y: weekdayCell.frame.size.height - 2, width: weekdayCell.frame.size.width, height: 1)
        }
        //
        
        // Fixes glitch where user opens timetable and rotates device -> it ruins layout.
        if (self.view.frame.size.width != width) {
            width = self.view.frame.size.width
            
            //spreadsheetView.removeFromSuperview()
            //spreadsheetView = SpreadsheetView()
            //self.viewDidLoad()
            //columnWidth = (self.view.frame.size.width - (40 + ( hairline * 9))) / 5
            self.spreadsheetView.reloadData()
            //self.viewDidAppear(true)
            //self.scrollTableViewToOffset()
            
            for weekdayCell in self.weekdayCells {
                //weekdayCell.layoutSubviews()
                //weekdayCell.setNeedsLayout()
                //weekdayCell.removeFromSuperview()
            }
            
            
        }
        //
        
    }
    var width: CGFloat = 0.0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if Int(scrollView.contentOffset.y) == 0 {

            spreadsheetView.contentOffset = CGPoint(x: 0, y: 1)
            spreadsheetView.scrollView.setContentOffset(CGPoint(x: 0, y: 1), animated: false)
            
        } else if Int(scrollView.contentOffset.y) == Int(scrollView.verticalOffsetForBottom) {
            
            spreadsheetView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y-1)
            spreadsheetView.scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y-1), animated: false)
        }
    }
    
    var backgroundView = UIView()
    var weekdayCells = [WeekdayCell(), WeekdayCell(), WeekdayCell(), WeekdayCell(), WeekdayCell()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTitleView()
        NotificationCenter.default.addObserver(self, selector: #selector(eventUpdated), name: NSNotification.Name.init("event_updated"), object: nil)
        
        self.configureAddEventButton()
        
        if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait {
            columnWidth = (UIScreen.main.bounds.width - (40 + (hairline * 9)))/5
        } else {
            columnWidth = (320 - (40 + (hairline * 9)))/5
        }
        
        self.view.addSubview(spreadsheetView)
        
        self.backgroundView = UIView(frame: self.view.frame)
        backgroundView.backgroundColor = UIColor(red: 24/255, green: 25/255, blue: 25/255, alpha: 1.0)
        self.view.addSubview(backgroundView)
        self.view.sendSubview(toBack: backgroundView)
        
        configTimeLabels()
        
        spreadsheetView.addSubview(line)
        spreadsheetView.addSubview(circle)
        spreadsheetView.addSubview(circleSub)
        spreadsheetView.stickyRowHeader = true
        
        
        queryEvents()
        
        spreadsheetView.bounces = true
        spreadsheetView.scrollView.bounces = true
        spreadsheetView.alwaysBounceVertical = false
        
        ///Because the last developer didn't realize the spreadsheet broke everytime user scrolled to bottom..
        //spreadsheetView.bounces = false
        //spreadsheetView.scrollView.bounces = false
        

        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.scrollView.delegate = self
        
        spreadsheetView.intercellSpacing = CGSize(width: hairline, height: hairline)
        spreadsheetView.gridStyle = .solid(width: hairline, color: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0))
        

        spreadsheetView.register(TimeCell.self, forCellWithReuseIdentifier: String(describing: TimeCell.self))
        spreadsheetView.register(StandardCell.self, forCellWithReuseIdentifier: String(describing: StandardCell.self))
        spreadsheetView.register(WeekdayCell.self, forCellWithReuseIdentifier: String(describing: WeekdayCell.self))
        spreadsheetView.register(UINib(nibName: String(describing: SlotCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SlotCell.self))
        
        didLoad = true

        
        self.splitViewController!.view.backgroundColor = UIColor.clear
        self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        self.extendedLayoutIncludesOpaqueBars = true
        
        if (firstTime == true) {
            //spreadsheetView.flashScrollIndicators()
            self.scrollTableViewToOffset()
            firstTime = false
        }
        
        
        
        
        //weekday cells at the top
        //self.view.frame.size.width / 5
        let topX = CGFloat(41.0)
        let topY = self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.height
        for (i, weekdayCell) in self.weekdayCells.enumerated() {
            //frame is set in viewWillLayout(..) so below line is irrelevant.
            self.weekdayCells[i] = WeekdayCell(frame: CGRect(x: topX, y: topY, width: self.columnWidth+1, height: 34))
            //self.mondayCell.colorBarView.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.0)
            self.weekdayCells[i].backgroundColor    = TTColorMateBlack
            self.weekdayCells[i].gridlines.top      = .solid(width: 1, color: TTColorMateBlack)
            self.weekdayCells[i].gridlines.bottom   = .solid(width: 2, color: UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.0))
            self.weekdayCells[i].gridlines.left     = .solid(width: 1, color: TTColorMateBlack)
            self.weekdayCells[i].gridlines.right    = .solid(width: 1, color: TTColorMateBlack)
            
            self.weekdayCells[i].label.font                         = UIFont.systemFont(ofSize: 12.0)
            self.weekdayCells[i].label.textColor                    = UIColor(red:241/255, green:241/255, blue:241/255, alpha:1.0)
            self.weekdayCells[i].label.textAlignment                = .center
            self.weekdayCells[i].label.adjustsFontSizeToFitWidth    = true
            self.weekdayCells[i].label.translatesAutoresizingMaskIntoConstraints = true
            
            self.weekdayCells[i].label.frame.origin.y = 13
            
            
            switch i {
            case 0:
                self.weekdayCells[i].label.text = "MON"
            case 1:
                self.weekdayCells[i].label.text = "TUE"
            case 2:
                self.weekdayCells[i].label.text = "WED"
            case 3:
                self.weekdayCells[i].label.text = "THU"
            case 4:
                self.weekdayCells[i].label.text = "FRI"
            default:
                print("")
            }
            
            //today column
            //let calendar = Calendar.current
            //print(Date().dayNumberOfWeek())
            if Date().dayNumberOfWeek() == (2 + (1 * i)) { //(2 + (1 * i)) because sun = 1, sat = 7
                self.weekdayCells[i].backgroundColor = TTColorTodayColumn
                self.weekdayCells[i].label.font      = UIFont.boldSystemFont(ofSize: 12.0)
                self.weekdayCells[i].label.textColor = UIColor.white
            } else {
                self.weekdayCells[i].backgroundColor = TTColorMateBlack
                self.weekdayCells[i].label.font      = UIFont.systemFont(ofSize: 12.0)
                self.weekdayCells[i].label.textColor = UIColor(red:241/255, green:241/255, blue:241/255, alpha:1.0)
            }
            //
            self.view.addSubview(self.weekdayCells[i])
        }
        
    }
    
    override func awakeFromNib() { //since iOS 13
        self.splitViewController!.delegate = self
    }
    
    var firstAppear = true
    override func viewWillAppear(_ animated: Bool) {
        self.selectedCell = nil
        queryEvents()
        spreadsheetView.reloadData()
        /*if (firstTime == true) {
         //spreadsheetView.flashScrollIndicators()
         self.scrollTableViewToOffset()
         firstTime = false
         }*/
        
        // Fixes glitch where user opens app in landscape, goes to timetable, and timetable looks like it's still in portrait mode.
        /*if (self.firstAppear == true) {
            spreadsheetView.removeFromSuperview()
            spreadsheetView = SpreadsheetView()
            self.viewDidLoad()
            columnWidth = (self.view.frame.size.width - (40 + ( hairline * 9))) / 5
            self.spreadsheetView.reloadData()
            self.viewDidAppear(true)
            self.scrollTableViewToOffset()
            
            self.firstAppear = false
        }*/
        //
    }
    
    var firstTime = true
    override func viewDidAppear(_ animated: Bool) {
        /*if (firstTime == true) {
            spreadsheetView.flashScrollIndicators()
            self.scrollTableViewToOffset()
            firstTime = false
        }*/
        if didLoad == true {
            didLoad = false
        }
        
        // Handle Paywall. //
        /*if (UserDefaults.standard.bool(forKey: "isSubscribed") == false && didAnimation == false) {
            self.navigationController!.navigationBar.isUserInteractionEnabled = false
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
            blurVisualEffectView.frame = self.view.frame
            blurVisualEffectView.frame.size = CGSize(width: 2000, height: 2000)
            blurVisualEffectView.center = self.view.center
            
            blurVisualEffectView.effect = nil
            
            let label = UILabel(frame: self.view.frame)
            label.frame.size = CGSize(width: 2000, height: 2000)
            label.center = self.navigationController!.view.center
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 18.0)
            label.text = "Subscribe to Unlock Timetable."
            
            self.navigationController!.view.addSubview(blurVisualEffectView)
            
            self.navigationController!.view.addSubview(label)
            
            label.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            label.alpha = 0
            
            UIView.animate(withDuration: 0.5, animations: {
                blurVisualEffectView.effect = blurEffect
                label.alpha = 1
                label.transform = CGAffineTransform.identity
            }) { (true) in
                let storyboard = UIStoryboard(name: "Subscription", bundle: nil)
                let subscriptionPlansVC = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlansViewController")
                self.present(subscriptionPlansVC, animated: true, completion: nil)
            }
            didAnimation = true
        }*/
        // //
    }
    var didAnimation = false
    
    @objc func eventUpdated() {
        self.viewWillAppear(true)
    }
    
    func scrollTableViewToOffset() {
        DispatchQueue.main.async {
            self.spreadsheetView.contentOffset = CGPoint(x: 0, y: self.scrollOffset)
            self.spreadsheetView.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollOffset), animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func configureAddEventButton() {
        let item    = UIBarButtonItem.init(image: UIImage.init(named: "Plus"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addEvent))
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc func addEvent() { //When top right '+' is tapped..
        self.removeDetailVC()
        let storyboard          = UIStoryboard.init(name: "CourseSelection", bundle: Bundle.main)
        let weeklyEditingTVC    = storyboard.instantiateViewController(withIdentifier: "WeeklyEditingTableViewController") as! WeeklyEditingTableViewController
        weeklyEditingTVC.course             = RLMCourse()
        weeklyEditingTVC.type               = ""
        weeklyEditingTVC.homeVC             = self.getHomeVC()
        weeklyEditingTVC.isFromTimeTableVC  = true
        self.splitViewController?.showDetailViewController(weeklyEditingTVC, sender: self.view)
    }
    
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 6
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return viewModel.hoursInDay.count + 1
    }
    
    /*func frozenRows(in spreadsheetView: SpreadsheetView) -> Int { //glitched
        return 1
    }*/
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if case 0 = column {
            return 40
        } else {
            return columnWidth
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        
        return rowHeight
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        
        // First column - Hours
        if indexPath.column == 0 {
            
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as! TimeCell
            cell.backgroundColor = TTColorMateBlack
            cell.gridlines.bottom = .solid(width: 1, color: TTColorMateBlack)
            cell.gridlines.top = .solid(width: 1, color: TTColorMateBlack)
            cell.gridlines.left = .solid(width: 1, color: TTColorMateBlack)
            cell.gridlines.right = .solid(width: 1, color: UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.0))
            
            return cell
        }
        
        //weekday cells at the top
        /*if indexPath.row == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: WeekdayCell.self), for: indexPath) as! WeekdayCell
            cell.backgroundColor    = TTColorMateBlack
            cell.gridlines.top      = .solid(width: 1, color: TTColorMateBlack)
            cell.gridlines.bottom   = .solid(width: 2, color: UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.0))
            cell.gridlines.left     = .solid(width: 1, color: TTColorMateBlack)
            cell.gridlines.right    = .solid(width: 1, color: TTColorMateBlack)
            
            cell.label.font                         = UIFont.systemFont(ofSize: 12.0)
            cell.label.textColor                    = UIColor(red:241/255, green:241/255, blue:241/255, alpha:1.0)
            cell.label.textAlignment                = .center
            cell.label.adjustsFontSizeToFitWidth    = true
            cell.label.translatesAutoresizingMaskIntoConstraints = true
            
            switch indexPath.column {
            case 1:
                cell.label.text = "MON"
            case 2:
                cell.label.text = "TUE"
            case 3:
                cell.label.text = "WED"
            case 4:
                cell.label.text = "THU"
            case 5:
                cell.label.text = "FRI"
            default:
                print("")
            }
            
            //today column
            let calendar = Calendar.current
            if calendar.component(.weekday, from: Date()) == indexPath.column+1 {
                cell.backgroundColor = TTColorTodayColumn
                cell.label.font      = UIFont.boldSystemFont(ofSize: 12.0)
                cell.label.textColor = UIColor.white
            } else {
                cell.backgroundColor = TTColorMateBlack
                cell.label.font      = UIFont.systemFont(ofSize: 12.0)
                cell.label.textColor = UIColor(red:241/255, green:241/255, blue:241/255, alpha:1.0)
            }
            //
            
            return cell
        }*/
        
        // Create cells for events.
        let indexDate           = viewModel.getDateFromIndex(index: indexPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        dateFormatter.locale = Locale.current
        //print("DATE FROM INDEX")
        //print(dateFormatter.string(from: indexDate))
        
        let indexTime           = Time(indexDate) //self.getOnlyTimeFromDate(date: indexDate)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateStyle = .full
        dateFormatter2.timeStyle = .full
        dateFormatter2.locale = Locale.current
        //print("TIME FROM INDEX")
        //print(String(indexTime.hour) + ":" + String(indexTime.minute))*/
        
        let calendar            = Calendar.current
        let weekIndexDate       = calendar.component(.weekday, from: indexDate)
        let dayOfWeekIndexDate  = DayOfWeek.init(id: weekIndexDate)!.stringValue()
        
        for event in eventsCurrentWeek {
            for token in event.tokens{
                if token.startDayOfWeek == dayOfWeekIndexDate && token.endTime != nil{
                    let tokenStartTimeOnly  = Time(token.startTime as Date)//.getOnlyTimeFromDate(date: token.startTime as Date)
                    let tokenEndTimeOnly    = Time(token.endTime as Date)//self.getOnlyTimeFromDate(date: token.endTime as Date)
                    
                    if ((tokenStartTimeOnly <= indexTime) && (indexTime < tokenEndTimeOnly)){
                        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: SlotCell.self), for: indexPath) as! SlotCell
                        cell.delegate           = self
                        if (event.course?.courseCode != nil) {
                            cell.slotTitle = event.course!.courseCode!
                        } else if (event.course?.courseName != nil) {
                            cell.slotTitle = event.course!.courseName
                        }
                        //print("Font Size \(self.view.frame.size.width/27.0)")
                        cell.slotTitleFont      = UIFont.boldSystemFont(ofSize: self.view.frame.size.width/30.0)
                        cell.slotLocation       = (event.location != nil && event.location!.count > 0) ? event.location! : ""
                        
                        cell.slotType           = (self.view.frame.size.width <= 370) ? "" : event.type
                        cell.slotTypeImage      = event.type
                        cell.slotTime           = viewModel.generateStringTime(start: token.startTime as Date, end: token.endTime! as Date)
                        
                        cell.weekday            = indexPath.column+1
                        cell.event              = event
                        
                        cell.labelColor         = UIColor.white
                        cell.backgroundColor    = event.course!.color!.getUIColorObject()
                        
                        
                        if (cell.slotTime == self.selectedCell?.slotTime && cell.weekday == self.selectedCell?.weekday){
                            cell.backgroundColor = UIColor(displayP3Red: CGFloat((event.course?.color?.red)!), green: CGFloat((event.course?.color?.green)!), blue: CGFloat((event.course?.color?.blue)!), alpha: 0.3)
                            cell.labelColor = UIColor(displayP3Red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
                        }
                        
                        cell.layer.masksToBounds = true
                        cell.layer.cornerRadius = 5
                        
                        return cell
                    }
                }
                
                                /*if (token.startTime as Date) <= indexDate {
                                    if indexDate < (token.endTime! as Date) {
                                        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: SlotCell.self), for: indexPath) as! SlotCell
                                        cell.delegate = self
                                        cell.slotTitle = event.course!.courseName
                                        cell.slotType = event.type
                                        cell.slotTime = viewModel.generateStringTime(start: token.startTime as Date, end: token.endTime! as Date)
                                        cell.backgroundColor = event.course!.color!.getUIColorObject() //colors[(event.course ?? "")]
                                        cell.weekday = indexPath.column+1
                
                                        return cell
                                    }
                                }*/
            }
            
        }
        
        
        //weekday cells at the top
        
        
       /* if indexPath.row == 0 {
            cell.backgroundColor    = TTColorMateBlack
            cell.gridlines.top      = .solid(width: 1, color: TTColorMateBlack)
            cell.gridlines.bottom   = .solid(width: 2, color: UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.0))
            cell.gridlines.left     = .solid(width: 1, color: TTColorMateBlack)
            cell.gridlines.right    = .solid(width: 1, color: TTColorMateBlack)
            
            cell.label.font                         = UIFont.systemFont(ofSize: 12.0)
            cell.label.textColor                    = UIColor(red:241/255, green:241/255, blue:241/255, alpha:1.0)
            cell.label.textAlignment                = .center
            cell.label.adjustsFontSizeToFitWidth    = true
            cell.label.translatesAutoresizingMaskIntoConstraints = true
            
            switch indexPath.column {
            case 1:
                cell.label.text = "MON"
            case 2:
                cell.label.text = "TUE"
            case 3:
                cell.label.text = "WED"
            case 4:
                cell.label.text = "THU"
            case 5:
                cell.label.text = "FRI"
            default:
                print("")
            }
        }*/
        //
        
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: StandardCell.self), for: indexPath) as! StandardCell
        
        //today column
        if calendar.component(.weekday, from: Date()) == indexPath.column+1 {
            cell.backgroundColor = TTColorTodayColumn
            cell.label.font      = UIFont.boldSystemFont(ofSize: 12.0)
            cell.label.textColor = UIColor.white
        } else {
            cell.backgroundColor = TTColorMateBlack
            cell.label.font      = UIFont.systemFont(ofSize: 12.0)
            cell.label.textColor = UIColor(red:241/255, green:241/255, blue:241/255, alpha:1.0)
        }
        //
        
        return cell
        //return spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: StandardCell.self), for: indexPath) as! StandardCell
    }
    
    /*override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        //Following 2 lines from github repo of library. Give it a try if the original solution doesn't work (well).
        //coordinator.animate(alongsideTransition: nil, completion: { _ in
            //self.spreadsheet.reloadData()})


        spreadsheetView.removeFromSuperview()
        spreadsheetView = SpreadsheetView()
        self.viewDidLoad()
        
        
        
//        columnWidth = (coordinator.containerView.bounds.height - (40 + ( hairline * 9))) / 5
        columnWidth = (size.width - (40 + ( hairline * 9))) / 5
        
        self.spreadsheetView.reloadData()
        self.viewDidAppear(true)
        
        self.scrollTableViewToOffset()


    }*/
    
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        let calendar = Calendar.current
        
        //Column is day, //Row is Time
        mergedCells = [CellRange]()

        for event in eventsCurrentWeek {
            
            for token in event.tokens{
                //print(token.startTime)
                //print(token.endTime)
                
                
                let weekDay         = DayOfWeek.init(day: token.startDayOfWeek)
                let eventStartDay   = weekDay?.weekNumber()
                
//                let eventStartDay = calendar.component(.weekday, from: token.startTime as Date)
                var eventEndDay = 7
                if token.endTime != nil{
                    eventEndDay = calendar.component(.weekday, from: token.endTime! as Date)                    
                }
                
//                if (eventStartDay != 1) && (eventStartDay != 1) && (eventEndDay != 7) && (eventEndDay != 7) {
                if (eventStartDay != 1) && (eventEndDay != 7) {
                    let eventStartHour = viewModel.formattedTime(format: "HH", time: token.startTime as Date)
                    let eventStartMin = viewModel.extraRow(date: token.startTime as Date)
                    
                    let eventEndHour = viewModel.formattedTime(format: "HH", time: token.endTime! as Date)
                    let eventEndMin = viewModel.extraRow(date: token.endTime! as Date)
                    
                    //Check if From cell is already merged
                    var fromRow = (eventStartHour*2)+eventStartMin
                    var fromColumn = eventStartDay!-1
                    
                    let toRow = (eventEndHour*2)+eventEndMin-1
                    let toColumn = fromColumn //eventEndDay-1
                    
                    while fromColumn != toColumn {
                        let cellRange1 = CellRange(from: (row: fromRow, column: fromColumn), to: (row: 47, column: fromColumn))
                        
                        fromColumn = fromColumn+1
                        fromRow = 0
                        
                        mergedCells.append(cellRange1)
                    }
                    if fromColumn == toColumn {
                        
                        let cellRange = CellRange(from: (row: fromRow, column: fromColumn), to: (row: toRow, column: toColumn))
                        
                        mergedCells.append(cellRange)
                    }
                }
            }
            
        }
        /*print("MergedCells")
        for cell in mergedCells {
            print(cell.from)
            print(cell.to)
        }*/
        return mergedCells
    }
    
    
    
    func getOnlyTimeFromDate(date:Date) -> Date {
        var calendarC       = Calendar.current
        calendarC.timeZone  = TimeZone.init(secondsFromGMT: 0)! //current
        
        let hour            = calendarC.component(.hour, from: date)
        let minutes         = calendarC.component(.minute, from: date)
        let seconds         = calendarC.component(.second, from: date)
        
        var components      = DateComponents.init()
        components.hour     = hour
        components.minute   = minutes
        components.second   = seconds
        
        let timeOnly       = calendarC.date(from: components)
        return timeOnly!
    }
    
    // Realm Query
    func queryEvents() {
        let realm = try! Realm()
//        let allEvents = realm.objects(RLMRecurringSchoolEvent.self)
        let allEvents = realm.objects(RLMRepeatingSchedule.self)
        
        let calendar = Calendar.current

//        var ar = [RLMRecurringSchoolEvent]()
        var ar = [RLMRepeatingSchedule]()
        
        
        for event in allEvents {
            //print(event)
            for token in event.tokens{
//                let currentweekOfYear   = calendar.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0))
//                let eventweekOfYear     = calendar.component(.weekOfYear, from: token.startTime as Date)
                
                let currentweekOfYear   =  calendar.component(.weekday, from: Date.init(timeIntervalSinceNow: 0))
                let currentDay          = DayOfWeek.init(id: currentweekOfYear)
                let eventweekOfYear     = token.startDayOfWeek //calendar.component(.weekOfYear, from: token.startTime as Date)
//                if eventweekOfYear == currentweekOfYear {
                if currentDay?.stringValue() == currentDay!.stringValue() {
                    ar.append(event)
                }
            }
        }
        self.eventsCurrentWeek = ar
    }
    
    func configureTimeIndicator() {
        
        let currentHour = viewModel.formattedTime(format: "HH", time: Date())
        let currentMinute = CGFloat(viewModel.formattedTime(format: "mm", time: Date()))
        
        let ym = (rowHeight * 2 * currentMinute) / 60
        let y = CGFloat(currentHour*2)*(rowHeight+(1 / UIScreen.main.scale))
        
        line.frame.origin = CGPoint(x: 20, y: (y+ym))
        line.bounds = line.frame
        line.frame.size = CGSize(width: self.view.bounds.width-20, height: 3)
            
        line.backgroundColor = slotColors[0]
        line.layer.shadowRadius = 3
        line.layer.shadowOpacity = 1
        line.layer.shadowColor = UIColor.black.cgColor
        line.layer.shadowOffset = CGSize(width: 0, height: 3)
        line.clipsToBounds = false

        circle.frame.origin = CGPoint(x: 10, y: (y+ym)-3)
        circle.frame.size = CGSize(width: 10, height: 10)
        
        circle.backgroundColor = slotColors[0]
        circle.layer.cornerRadius = 5
        
        circleSub.frame = circle.frame
        circleSub.bounds = circle.bounds
        circleSub.frame.size = CGSize(width: 5, height: 5)
        circleSub.center = circle.convert(circle.center, from: circleSub)
        circleSub.backgroundColor = UIColor.black
        circleSub.layer.cornerRadius = 2.5

    }
    
    func segueFromSlot(event: RLMRepeatingSchedule, cell: SlotCell) {
        self.removeDetailVC()
        self.selectedCell       = cell
        self.spreadsheetView.reloadData() ///
        
        let storyboard          = UIStoryboard.init(name: "CourseSelection", bundle: Bundle.main)
        let weeklyEditingTVC    = storyboard.instantiateViewController(withIdentifier: "WeeklyEditingTableViewController") as! WeeklyEditingTableViewController
        weeklyEditingTVC.course = event.course
        weeklyEditingTVC.type   = event.type
        weeklyEditingTVC.homeVC = self.getHomeVC()
        weeklyEditingTVC.isFromTimeTableVC = true
        
        self.splitViewController?.showDetailViewController(weeklyEditingTVC, sender: cell)
    }
    
    func configTimeLabels() {
        var y = 0.0 //-Double(rowHeight) //Double(rowHeight) //0.0
        for item in viewModel.hoursInDay {
            
            let label = UILabel()
            spreadsheetView.scrollView.addSubview(label)
            
            label.text          = item
            label.frame         = CGRect(x: 10.0, y: y, width: 25.0, height: 15.0)
            label.font          = UIFont.preferredFont(forTextStyle: .caption1)
            label.textColor     = UIColor.white
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.translatesAutoresizingMaskIntoConstraints = true
            
            
            if item == "12AM" {
                y += Double(rowHeight)-((Double(label.frame.height/2)))
            } else {
                y += Double(rowHeight)+Double(hairline)
            }
        }
    }
    
    //This function is not needed. If you have an issue with splitviewcontroller handling VCs, look at main.storyboard for how to do it properly. (two potential transitions can occur based on the circumstance)
    func removeDetailVC() {
        let navController = ((self.splitViewController?.viewControllers.count)! > 1) ? self.splitViewController?.viewControllers[1] : nil
        if (navController != nil) {
            if (navController!.isKind(of: UINavigationController.self)){
                let nav = navController as! UINavigationController
                nav.viewControllers = []
            }
        }
    }
    
    func getHomeVC() -> HomeworkViewController? {
        for tableView in TaskManagerTracker.taskManagers() {
            if (tableView?.parentViewController is HomeworkViewController) {
                return tableView!.parentViewController as! HomeworkViewController
            }
        }
        return nil
    }
    
    //MARK:- SplitViewController
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        //Since splitViewController!.showViewController changes secondaryViewController to no longer be a UINavigationController, this must first be checked for there to even be a BlankVC.
        //print("collapse occurred.")
        if let secondaryNavController = secondaryViewController as? UINavigationController {
            let bottomSecondaryView = secondaryNavController.viewControllers.first
            if (bottomSecondaryView == nil) {
                return true
            }
            if (bottomSecondaryView!.isKind(of: BlankViewController.self)) {
                return true
            }
            
            let masterVC = primaryViewController as! UITabBarController
            let navController = masterVC.selectedViewController! as! UINavigationController
            navController.viewControllers.append(bottomSecondaryView!)
            if (secondaryNavController.viewControllers.count != 0) {
                for index in 0...(secondaryNavController.viewControllers.count - 1) {
                    let vc = secondaryNavController.viewControllers[index]
                    navController.pushViewController(vc, animated: false)
                }
            }
            return true
        }
        
        return false
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        let masterVC = splitViewController.viewControllers[0] as! UITabBarController
        //print("showDetailVC")
        if splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact {
            masterVC.selectedViewController?.show(vc, sender: sender)
        } else {
            let navController = self.storyboard!.instantiateViewController(withIdentifier: "BlankNavigationController") as! UINavigationController
            if let detailNavController = splitViewController.viewControllers[1] as? UINavigationController {
                if (sender == nil || ((sender as? UIView)?.isDescendant(of: detailNavController.view) == true || (detailNavController.visibleViewController != nil && (sender! as? UIView)?.isDescendant(of: detailNavController.visibleViewController!.view) == true))) {
                    detailNavController.pushViewController(vc, animated: true)
                    return true
                }
            }
            navController.viewControllers = [vc]
            splitViewController.viewControllers = [masterVC, navController]
        }
        return true
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        let masterVC = splitViewController.viewControllers[0] as! UITabBarController
        //print("separateSecondVCFromPrimaryVC")
        if let navController = masterVC.selectedViewController as? UINavigationController {
            if navController.viewControllers.count > 1 {
                let poppedVC = navController.popViewController(animated: false)!
                if (poppedVC is UINavigationController) {
                    return poppedVC
                } else {
                    let newNavController = self.storyboard!.instantiateViewController(withIdentifier: "BlankNavigationController") as! UINavigationController
                    if (navController.viewControllers.count > 1) {
                        newNavController.viewControllers = []
                        newNavController.viewControllers.append(contentsOf: navController.popToRootViewController(animated: false)!)
                        newNavController.pushViewController(poppedVC, animated: false)
                    } else {
                        newNavController.viewControllers = [poppedVC]
                    }
                    
                    return newNavController
                }
            }
        }
        
        return self.storyboard!.instantiateViewController(withIdentifier: "BlankTabBarController") as! UITabBarController
        //return nil //(w/o UITabBarController)
    }
    
    
}

extension UIScrollView {
    
    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
    
    
    
    
}
