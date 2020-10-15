//
//  TaskManagerTracker.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2019-07-13.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit

//Simply a class that obfuscates communication to the AppDelegate instance for tracking TaskManagers.
//TaskManagers are VCs that contain HWCells.
class TaskManagerTracker: NSObject {
    
    class func taskManagers() -> [UITableView?] {
        return (UIApplication.shared.delegate as! AppDelegate).taskManagers
    }
    
    class func addTaskManager(tableView: UITableView) {
        (UIApplication.shared.delegate as! AppDelegate).addTaskManager(tableView: tableView)
    }

}
