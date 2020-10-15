//
//  ColorPickerTableTableViewController.swift
//  B4Grad
//
//  Created by Sunil Zalavadiya on 12/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class ColorPickerTableViewController: UITableViewController {

    var addCourseVC: AddCourseTableViewController?
    var editScheduleVc: ScheduleEditorViewController?
    var colorStaticValue: Int!
    
    var colorTypesArray = [ColorTypeModel]()
    var colorGroupsArray = [ColorGroupModel]()
    var usedStaticColors = [Int]()
    
    var coursesQuery: Results<RLMCourse> {
        let realm = try! Realm()
        return realm.objects(RLMCourse.self).sorted(byKeyPath: "createdDate", ascending: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        setupUI()
        getUsedColors()
        colorGroupsArray.append(contentsOf: ColorGroupModel.getGroupedColors())
        colorTypesArray.append(contentsOf: ColorTypeModel.getAllColorTypes())
    }
    
    private func setupUI() {
        self.title = "Select Color"
        tableView.sectionHeaderHeight = 60.0
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.contentInset = UIEdgeInsetsMake(18.0, 0.0, 0.0, 0.0)
        tableView.register(UINib(nibName: "PaletteTableViewCell", bundle: nil), forCellReuseIdentifier: "PaletteTableViewCell")
        tableView.register(UINib(nibName: "IndividualPaletteTableViewCell", bundle: nil), forCellReuseIdentifier: "IndividualPaletteTableViewCell")
    }
    
    private func getUsedColors() {
        usedStaticColors.removeAll()
        var staticColors = ColorDataModel.getAllColorsArray().map { (colorModel) -> Int in
            return colorModel.colorStaticValue
        }//[1, 2, 3, 4, 5]
        for currentCourse in self.coursesQuery {
            if (staticColors.contains(currentCourse.colorStaticValue)) {
                usedStaticColors.append(currentCourse.colorStaticValue)
                staticColors.removeObject(object: currentCourse.colorStaticValue)
            }
        }
    }
    
    //MARK: - Actions
    @objc private func onBtnInfor(_ sender: UIButton) {
        let colorGroup = colorGroupsArray[sender.tag]
        let alertController = UIAlertController(title: colorGroup.name, message: colorGroup.info!, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return colorGroupsArray.count
        //return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 21.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let colorGroupModel = colorGroupsArray[section]
        let sectionHeader = SectionHeaderView.construct(colorGroupModel.name, owner: tableView)
        if(colorGroupModel.showInfo) {
            sectionHeader.btnInfo.isHidden = false
            sectionHeader.btnInfo.tag = section
            sectionHeader.btnInfo.addTarget(self, action: #selector(onBtnInfor(_:)), for: .touchUpInside)
        }
        return sectionHeader
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return colorTypesArray.count
        return colorGroupsArray[section].palettes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let colorTypeModel = colorTypesArray[indexPath.row]
        let colorTypeModel = colorGroupsArray[indexPath.section].palettes[indexPath.row]
        if colorTypeModel.paletteType == .palette {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaletteTableViewCell", for: indexPath) as! PaletteTableViewCell
            cell.selectionStyle = .none
            cell.delegate = self
            // Configure the cell...
            cell.configure(colorTypeModel: colorTypeModel)
            cell.checkForUsedColors(usedStaticColors: usedStaticColors)
            cell.setColorStaticValue(colorStaticValue: colorStaticValue)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IndividualPaletteTableViewCell", for: indexPath) as! IndividualPaletteTableViewCell
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.delegate = self
            // Configure the cell...
            cell.configure(colorTypeModel: colorTypeModel)
            cell.checkForUsedColors(usedStaticColors: usedStaticColors)
            cell.setColorStaticValue(colorStaticValue: colorStaticValue)
            
            return cell
        }
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - PaletteTableViewHeaderFooterViewDelegate
extension ColorPickerTableViewController: PaletteTableViewHeaderFooterViewDelegate {
    func paletteTableViewHeaderFooterView(headerView: PaletteTableViewHeaderFooterView, didSelect color: UIColor, colorStaticValue: Int) {
        
        if let addCourseVc = self.addCourseVC {
            let indexPath = IndexPath(row: 0, section: 1)
            addCourseVc.sections[indexPath.section][indexPath.row].color = color
            addCourseVc.sections[indexPath.section][indexPath.row].colorStaticValue = colorStaticValue
            let courseColourCell = addCourseVc.tableView.cellForRow(at: indexPath) as! CourseColorTableViewCell
            courseColourCell.backgroundColor = color
            courseColourCell.bgImageView.backgroundColor = color
            addCourseVc.tableView.reloadData()
        } else if let editScheduleVc = self.editScheduleVc {
            let realm = try! Realm()
            realm.beginWrite()
            editScheduleVc.course.color?.setColor(color: color)
            editScheduleVc.course.colorStaticValue = colorStaticValue
            do {
                try realm.commitWrite()
            } catch let error {
                print("error = ", error)
            }
            editScheduleVc.tableView.reloadData()
            editScheduleVc.homeVC.tableView.reloadData()
        }
        //self.navigationController!.popViewController(animated: true)
    }
}

//MARK: - PaletteTableViewCellDelegate
extension ColorPickerTableViewController: PaletteTableViewCellDelegate {
    func palettePaletteTableViewCell(cell: PaletteTableViewCell, didSelect color: UIColor, colorStaticValue: Int) {
        self.colorStaticValue = colorStaticValue
        tableView.reloadData()
        if let addCourseVc = self.addCourseVC {
            let indexPath = IndexPath(row: 0, section: 1)
            addCourseVc.sections[indexPath.section][indexPath.row].color = color
            addCourseVc.sections[indexPath.section][indexPath.row].colorStaticValue = colorStaticValue
            let courseColourCell = addCourseVc.tableView.cellForRow(at: indexPath) as! CourseColorTableViewCell
            courseColourCell.backgroundColor = color
            courseColourCell.bgImageView.backgroundColor = color
            addCourseVc.tableView.reloadData()
        } else if let editScheduleVc = self.editScheduleVc {
            let realm = try! Realm()
            realm.beginWrite()
            editScheduleVc.course.color?.setColor(color: color)
            editScheduleVc.course.colorStaticValue = colorStaticValue
            do {
                try realm.commitWrite()
            } catch let error {
                print("error = ", error)
            }
            editScheduleVc.tableView.reloadData()
            editScheduleVc.homeVC.tableView.reloadData()
        }
        //self.navigationController!.popViewController(animated: true)
    }
}

//MARK: - PaletteTableViewCellDelegate
extension ColorPickerTableViewController: IndividualPaletteTableViewCellDelegate {
    func individualPaletteTableViewCell(cell: IndividualPaletteTableViewCell, didSelect color: UIColor, colorStaticValue: Int) {
        self.colorStaticValue = colorStaticValue
        tableView.reloadData()
        if let addCourseVc = self.addCourseVC {
            let indexPath = IndexPath(row: 0, section: 1)
            addCourseVc.sections[indexPath.section][indexPath.row].color = color
            addCourseVc.sections[indexPath.section][indexPath.row].colorStaticValue = colorStaticValue
            let courseColourCell = addCourseVc.tableView.cellForRow(at: indexPath) as! CourseColorTableViewCell
            courseColourCell.backgroundColor = color
            courseColourCell.bgImageView.backgroundColor = color
            addCourseVc.tableView.reloadData()
        } else if let editScheduleVc = self.editScheduleVc {
            let realm = try! Realm()
            realm.beginWrite()
            editScheduleVc.course.color?.setColor(color: color)
            editScheduleVc.course.colorStaticValue = colorStaticValue
            do {
                try realm.commitWrite()
            } catch let error {
                print("error = ", error)
            }
            editScheduleVc.tableView.reloadData()
            editScheduleVc.homeVC.tableView.reloadData()
        }
        //self.navigationController!.popViewController(animated: true)
    }
}
