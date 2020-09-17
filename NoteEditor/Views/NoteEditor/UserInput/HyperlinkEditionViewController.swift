//
//  HyperlinkEditionViewController.swift
//  Note Editor
//
//  Created by Thang Pham on 9/9/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

struct HyperlinkCellInfo {
    var title: String
    var preemptedText: String
}

class HyperlinkEditionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var centerYConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var completion: ((String?, String?) -> Void)?
    var hyperlinkCellInfos: [HyperlinkCellInfo]!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerNotifications()
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterNotifications()
        reset("","")
    }
    
    func reset(_ preemptedTitle: String, _ preemptedLink: String) {
        hyperlinkCellInfos = [HyperlinkCellInfo(title: "TITLE", preemptedText: preemptedTitle), HyperlinkCellInfo(title: "LINK", preemptedText: preemptedLink)]
    }
    
    // MARK: - Notifications
    
    func registerNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        let keyboardRectAsObject = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        var keyboardRect = CGRect.zero
        keyboardRectAsObject.getValue(&keyboardRect)
        UIView.animate(withDuration: 0.3) {
            self.centerYConstraint.constant = -keyboardRect.height + self.containerView.bounds.height/2.0
        }
    }
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.centerYConstraint.constant = 0
        }
    }
    
    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: Actions

    @IBAction func cancelResult(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveResult(_ sender: Any) {
        var inputs = [String]()
        for (idx, _) in self.hyperlinkCellInfos.enumerated() {
            let cell = tableView.cellForRow(at: IndexPath(row: idx, section: 0)) as! HyperlinkEditionTableViewCell
            inputs.append(cell.textView.text)
        }
    
        if inputs.count == 2 {
            self.dismiss(animated: true) {
                self.completion?(inputs[0], inputs[1])
            }
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func tapOutside(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        if !containerView.frame.contains(location) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - TableView Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hyperlinkCellInfos.count
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CGFloat(104)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HyperlinkEditionTableViewCellID", for: indexPath) as! HyperlinkEditionTableViewCell
        cell.title.text = hyperlinkCellInfos[indexPath.row].title
        cell.textView.text = hyperlinkCellInfos[indexPath.row].preemptedText
        return cell
    }
}
