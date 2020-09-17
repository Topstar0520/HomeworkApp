//
//  EmptySearchResultsView.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-11.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class EmptySearchResultsView: UIView {

    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet var faceImageView: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var subheaderLabel: UILabel!
    @IBOutlet var requestCourseButton: UIButton!
    var owner : AnyObject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.requestCourseButton.layer.borderColor = UIColor.white.cgColor
        self.requestCourseButton.layer.borderWidth = 1
        self.requestCourseButton.layer.cornerRadius = self.requestCourseButton.frame.size.height / 3
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //self.visualEffectView.layer.cornerRadius = self.visualEffectView.frame.size.width / 9 //To-Fix: Base on height, not width. Or both width & height.
        //self.visualEffectView.layer.cornerRadius = (self.visualEffectView.frame.size.width / 12) + (self.visualEffectView.frame.size.height / 12)
        self.visualEffectView.layer.cornerRadius = self.visualEffectView.frame.size.height / 9
        self.visualEffectView.layer.masksToBounds = true
    }
    
    @IBAction func requestCoursesButtonTapped(_ sender: AnyObject) {
        let ownerAsVC = owner as! UIViewController
        let alertVC = UIAlertController(title: "Request Course", message: "Please fill in the information below.", preferredStyle: .alert)
        //alertVC.addTextFieldWithConfigurationHandler({ textField in textField.placeholder = NSLocalizedString("University", comment: "University")})
        alertVC.addTextField(configurationHandler: { textField in textField.placeholder = NSLocalizedString("Course Code", comment: "Course")})
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in }))
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            //let universityString = alertVC.textFields?.first?.text
            let courseString = alertVC.textFields?.last?.text
            //Do something with information.
            let confirmVC = UIAlertController(title: "Thank You.", message: "Please come back soon.", preferredStyle: .alert)
            confirmVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in }))
            ownerAsVC.present(confirmVC, animated: true, completion: { })
        }))
        ownerAsVC.present(alertVC, animated: true, completion: { })
        
        //let coursesVC = ownerAsVC.storyboard!.instantiateViewControllerWithIdentifier("CoursesNavigationViewController") as! CoursesNavigationViewController
        //ownerAsVC.presentViewController(coursesVC, animated: true, completion: { })
    }
    
    class func construct(_ owner : AnyObject) -> EmptySearchResultsView {
        var nibViews = Bundle.main.loadNibNamed("EmptySearchResultsView", owner: owner, options: nil)
        let emptySearchResultsView = nibViews?[0] as! EmptySearchResultsView
        emptySearchResultsView.owner = owner
        return emptySearchResultsView
    }

}
