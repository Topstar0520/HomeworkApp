
//
//  CellEditingProtocol.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-06-13.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit

protocol CellEditingProtocol: UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var cellEditingTVC: CellEditingTableViewController! { get set }
    var dictionary :[Int:Array<ScheduleRowContent>] { get set }
    var task: RLMTask! { get set }
    var homeVC: HomeworkViewController? { get set }
    var taskManagerVC: UIViewController? { get set } //i.e. homeVC, scheduleEditorVC, etc.
    var placeholderTitleText: String! { get set }
    var mode: TaskEditingMode { get set }
    
    func textFieldEdited(sender: UITextView) //Executes whenever the textField is edited for the title of a task.
    func getIndexWithCellIdentifier(identifier: String) -> IndexPath?
    func generatePlaceholderTitle(isNewCourse: Bool) -> String
}
