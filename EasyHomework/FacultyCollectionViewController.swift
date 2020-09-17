//
//  FacultyCollectionViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2018-02-18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

class FacultyCollectionViewController: UICollectionViewController {

    var addCourseVC: AddCourseTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Select Icon"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.addCourseVC.defaultFacultiesArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FacultyIconCell", for: indexPath) as! FacultyIconCollectionViewCell
    
        // Configure the cell
        //print(self.addCourseVC.defaultFacultiesArray[indexPath.row][0])
        cell.imageView.image = UIImage(named: self.addCourseVC.defaultFacultiesArray[indexPath.row][0])
        cell.label.text = self.addCourseVC.defaultFacultiesArray[indexPath.row][0]
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FacultyIconCollectionViewCell
        cell.backgroundColor = UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FacultyIconCollectionViewCell
        cell.backgroundColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1.0)
    }
    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FacultyIconCollectionViewCell
        cell.backgroundColor = UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0)
        self.addCourseVC.array[0].optionString1 = self.addCourseVC.defaultFacultiesArray[indexPath.row][0]
        self.addCourseVC.array[0].optionBool1 = true
        let courseNameCell = self.addCourseVC.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CourseNameTableViewCell
        courseNameCell.facultyButton.setImage(UIImage(named: self.addCourseVC.array[0].optionString1!), for: .normal)
        self.navigationController!.popViewController(animated: true)
    }
    

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
