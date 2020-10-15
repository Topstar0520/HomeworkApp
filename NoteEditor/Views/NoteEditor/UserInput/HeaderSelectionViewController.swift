//
//  HeaderSelectionViewController.swift
//  Note Editor
//
//  Created by Thang Pham on 9/9/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class HeaderSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    @IBOutlet weak var containerView: UIView!
    var headerType = TextHeaderType.NoHeader
    var completion: ((TextHeaderType) -> Void)?
    var headers = ["H1", "H2", "H3", "No header"]
    
    // MARK: - Actions
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapOutside(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        if !containerView.frame.contains(location) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - TableView Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(60)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderSelectionTableViewCellID", for: indexPath) as! HeaderSelectionTableViewCell
        cell.title.text = headers[indexPath.row]
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        headerType = TextHeaderType(rawValue: indexPath.row + 1)!
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true) {
            self.completion?(self.headerType)
        }
    }
}
