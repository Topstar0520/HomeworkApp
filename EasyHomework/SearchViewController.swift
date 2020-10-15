//
//  SearchViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-04-23.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var backgroundImageView: UIImageView!
    var searchController: UISearchController!
    var backBarButtonItem: UIBarButtonItem!
    var searchButtonTapped = false
    @IBOutlet var titleLabel: SpringLabel!
    @IBOutlet var loadingIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchResultsVC = self.storyboard!.instantiateViewController(withIdentifier: "SearchResultsTableViewController") as! SearchResultsTableViewController
        searchResultsVC.searchController = self
        
        searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController.searchResultsUpdater = searchResultsVC
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.dimsBackgroundDuringPresentation = true
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Courses"
        searchController.view.backgroundColor = UIColor.clear
        searchController.searchBar.keyboardAppearance = .dark
        
        self.setSearchBarCaretColor(UIColor(red: 0.24, green: 0.34, blue: 0.19, alpha: 1.0))
        self.setSearchBarFontSize(17.0)
        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true
        self.backBarButtonItem = self.navigationItem.leftBarButtonItem
        self.backgroundImageView.clipsToBounds = true
        
        self.titleLabel.alpha = 0
        self.titleLabel.layer.shadowColor = UIColor.black.cgColor
        self.titleLabel.layer.shadowOpacity = 0.8
        self.titleLabel.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.titleLabel.layer.shouldRasterize = true
        self.titleLabel.layer.rasterizationScale = UIScreen.main.scale
        
        self.loadingIndicatorView.layer.zPosition = CGFloat.greatestFiniteMagnitude
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.perform(#selector(SearchViewController.showKeyboard), with: nil, afterDelay: 0.01)
        searchBarTextDidBeginEditing(searchController.searchBar)
    }
    
    @objc func showKeyboard() {
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    func hideKeyboard() {
        self.searchController.searchBar.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.delay = 0.1
        self.titleLabel.animation = "zoomIn"
        self.titleLabel.duration = 0.6
        self.titleLabel.animate()
        
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
    
    func setSearchBarCaretColor(_ color : UIColor) {
        let view = searchController.searchBar.subviews[0]
        let subViewsArray = view.subviews
        for subView in subViewsArray {
            if subView.isKind(of: UITextField.self) {
                subView.tintColor = color
            }
        }
    }
    
    func setSearchBarFontSize(_ pointSize : CGFloat) {
        let view = searchController.searchBar.subviews[0]
        let subViewsArray = view.subviews
        for subView in subViewsArray {
            if subView.isKind(of: UITextField.self) {
                let textField = subView as! UITextField
                textField.font = UIFont.systemFont(ofSize: pointSize)
            }
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        //dispatch_async(dispatch_get_main_queue(), { searchController.searchBar.becomeFirstResponder() })
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //self.navigationItem.setHidesBackButton(true, animated: true) //This doesn't animate for some reason, so don't use it.
        if (UI_USER_INTERFACE_IDIOM() != .pad) { //Because the iPad (for some reason) doesn't ever show the Cancel button, so keep the back button.
            UIView.animate(withDuration: 0.3, animations: { self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView()) }, completion: { Void in
                self.navigationItem.setHidesBackButton(true, animated: false)
            })
        }
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if (self.searchButtonTapped == false) {
            self.navigationItem.leftBarButtonItem = self.backBarButtonItem
            self.navigationItem.setHidesBackButton(false, animated: true)
        } else {
            self.searchButtonTapped = false
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem
        self.navigationItem.setHidesBackButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchButtonTapped = true
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
