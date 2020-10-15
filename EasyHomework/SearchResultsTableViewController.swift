//
//  SearchResultsViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-04-29.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import Parse

class SearchResultsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var resultsArray = [CourseResult]()
    var emptySearchResultsView : EmptySearchResultsView!
    
    var keyboardActive = false
    var keyboardHeight : CGFloat = 0.0
    
    var searchController : SearchViewController!
    var query = PFQuery(className: "Course")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.estimatedRowHeight = 140
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.keyboardDismissMode = .onDrag
        
        self.emptySearchResultsView = EmptySearchResultsView.construct(self) as EmptySearchResultsView
        emptySearchResultsView.translatesAutoresizingMaskIntoConstraints = true
        self.emptySearchResultsView.isHidden = true
        self.tableView.addSubview(emptySearchResultsView)
        
        query.whereKey("university", equalTo: "Western University")
        query.limit = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if #available(iOS 10, *) {
            self.automaticallyAdjustsScrollViewInsets = false
            self.tableView.contentInset.top = UIApplication.shared.statusBarFrame.size.height + self.searchController.navigationController!.navigationBar.frame.size.height
        }
        self.registerKeyboardNotifications()
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.unregisterKeyboardNotifications()
    }
    
    var lastSearch = ""
    func updateSearchResults(for searchController: UISearchController) {
        /*
         `updateSearchResultsForSearchController(_:)` is called when the controller is
         being dismissed to allow those who are using the controller they are search
         as the results controller a chance to reset their state. No need to update
         anything if we're being dismissed.
         */
        guard searchController.isActive else { return }
        if (lastSearch == searchController.searchBar.text!) {
            return
        }
        self.lastSearch = searchController.searchBar.text!
        query.cancel()
        self.emptySearchResultsView.isHidden = true
        
        if (searchController.searchBar.text?.characters.count == 0) {
            resultsArray.removeAll()
            self.tableView.reloadData()
        }
        
        if ((searchController.searchBar.text?.characters.count)! > 0) {
            self.searchController.loadingIndicatorView.startAnimating()
            var searchString = searchController.searchBar.text!
            searchString = searchString.lowercased()
            var searchStringArray = searchString.components(separatedBy: " ")
            searchStringArray = searchStringArray.filter { $0 != "" }
            //print(searchStringArray.description)
            query.whereKey("searchTerms", containsAllObjectsIn: searchStringArray)
            query.findObjectsInBackground(block: { (results, error) -> Void in
                if (error == nil) {
                    self.resultsArray = []
                    let courseResultsArray = results! as [PFObject]
                    for result in courseResultsArray {
                        self.resultsArray.append(CourseResult(coursePFObject: result, courseCode: result.object(forKey: "courseCode") as! String, courseName: result.object(forKey: "courseName") as! String, university: result.object(forKey: "university") as! String, faculty: result.object(forKey: "faculty") as! String))
                    }
                    self.searchController.loadingIndicatorView.stopAnimating()
                    self.tableView.reloadData()
                    if (self.resultsArray.count == 0) {
                        self.emptySearchResultsView.isHidden = false
                    } else {
                        self.emptySearchResultsView.isHidden = true
                    }
                } else {
                    print(error?.localizedDescription)
                    self.searchController.loadingIndicatorView.stopAnimating()
                }
            })
        }
        
        /*self.tableView.reloadData()
        if (self.tableView.numberOfRowsInSection(0) == 0) {
            self.emptySearchResultsView.hidden = false
        } else {
            self.emptySearchResultsView.hidden = true
        }*/
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if (self.keyboardActive == true) {
            self.emptySearchResultsView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height - self.keyboardHeight - self.tableView.contentInset.top)
            self.emptySearchResultsView.setNeedsLayout()
        } else {
            self.emptySearchResultsView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height - self.tableView.contentInset.top)
            self.emptySearchResultsView.setNeedsLayout()
        }
        if #available(iOS 10, *) {
            self.automaticallyAdjustsScrollViewInsets = false
            self.tableView.contentInset.top = UIApplication.shared.statusBarFrame.size.height + self.searchController.navigationController!.navigationBar.frame.size.height
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellContent: CourseResult = self.resultsArray[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseResultTableViewCell", for: indexPath) as! CourseResultTableViewCell
        cell.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        cell.backgroundColor = UIColor.clear
        cell.courseLabel.text = cellContent.courseCode + " - " + cellContent.courseName
        cell.universityLabel.text = cellContent.university
        cell.facultyLabel.text = cellContent.faculty
        
        cell.leftHandSideImageView.image = UIImage(named: cellContent.faculty)
        cell.leftHandSideImageView.layer.shadowColor = UIColor.black.cgColor
        cell.leftHandSideImageView.layer.shadowOpacity = 0.6
        cell.leftHandSideImageView.layer.shouldRasterize = true
        cell.leftHandSideImageView.layer.rasterizationScale = UIScreen.main.scale
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let schedulesVC = self.storyboard!.instantiateViewController(withIdentifier: "SchedulesViewController") as! SchedulesViewController
        schedulesVC.selectedCourse = self.resultsArray[(indexPath as NSIndexPath).row]
        self.searchController.show(schedulesVC, sender: tableView)
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(SearchResultsTableViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchResultsTableViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if (UI_USER_INTERFACE_IDIOM() != .phone) { //Because devices like iPads don't have they keyboards affect the error screen visibility much.
            return
        }
        if let keyboardFrame = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            UIView.animate(withDuration: 0.6, animations: { self.emptySearchResultsView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height - keyboardFrame.height - self.tableView.contentInset.top)
                self.emptySearchResultsView.layoutIfNeeded()
            })
            //self.emptySearchResultsView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height - keyboardFrame.height - self.tableView.contentInset.top)
            self.keyboardActive = true
            self.keyboardHeight = keyboardFrame.height
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if (UI_USER_INTERFACE_IDIOM() != .phone) {
            return
        }
        UIView.animate(withDuration: 0.6, animations: { self.emptySearchResultsView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height - self.tableView.contentInset.top)
            self.emptySearchResultsView.layoutIfNeeded()
        })
        self.keyboardActive = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
