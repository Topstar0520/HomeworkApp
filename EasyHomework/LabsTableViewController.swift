//
//  LabsTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-04.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class LabsTableViewController: UITableViewController, UITextFieldDelegate {
    
    var dictionary :[Int:Array<ScheduleRowContent>] = [0 : [ScheduleRowContent(identifier: "InstructionsCell")], 1 : [ScheduleRowContent(identifier: "LabCell")] ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 71
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let selectedRowIndexPath = self.tableView.indexPathForSelectedRow
        if ((selectedRowIndexPath) != nil) {
            self.tableView.deselectRow(at: selectedRowIndexPath!, animated: true)
            self.transitionCoordinator?.notifyWhenInteractionEnds({ context in
                if (context.isCancelled) {
                    self.tableView.selectRow(at: selectedRowIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
                }
            })
        }
    }
    
    override func unwindToViewController(sender: UIStoryboardSegue) {
        super.unwindToViewController(sender: sender)
        if (sender.identifier == "UnwindToPreviousVC") {
            let sourceVC = sender.source as! LabEditingTableViewController
            //get information from sourceVC.
            let cellContent = ScheduleRowContent(identifier: "LabCell")
            cellContent.toggle = true
            self.dictionary[1]?.insert(cellContent, at: 0)
            self.tableView.reloadData()
            self.title = "Lab Selected"
            //Modify ScheduleEditorVC
            let scheduleEditorVC = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 3] as! ScheduleEditorViewController
            //Here is where the SelectLabCell or SelectTutorialCell is updated.
            //scheduleEditorVC.dictionary[6]![0].identifier = "SelectTutorialCell"
            let indexPathForSelectedRow = scheduleEditorVC.tableView.indexPathForSelectedRow!
            scheduleEditorVC.tableView.reloadRows(at: [indexPathForSelectedRow], with: .none)
            scheduleEditorVC.tableView.selectRow(at: indexPathForSelectedRow, animated: false, scrollPosition: .none)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.dictionary.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dictionary[section]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellContent = dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row] as ScheduleRowContent
        let cell = tableView.dequeueReusableCell(withIdentifier: cellContent.identifier, for: indexPath)
        
        if (cellContent.identifier == "LocationCell") {
            let locationCell = cell as! LocationTableViewCell
            locationCell.textField.delegate = self
        }
        
        if (cellContent.toggle == true) {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        if (section == 1) {
            let headerView = SectionHeaderView.construct("Labs", owner: tableView)
            return headerView
        }
        
        let invisView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        invisView.backgroundColor = UIColor.clear
        return invisView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return CGFloat.leastNormalMagnitude
        } else {
            return 21.0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            cell.backgroundColor = UIColor(red: 36/255, green: 41/255, blue: 36/255, alpha: 1.0)
            if (cell.contentView.backgroundColor != UIColor.clear) {
                cell.backgroundColor = cell.contentView.backgroundColor
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "ExistingLab") {
            segue.destination.title = "Lab"
        }
        
        if (segue.identifier == "NewLab") {
            segue.destination.title = "Create Lab"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
