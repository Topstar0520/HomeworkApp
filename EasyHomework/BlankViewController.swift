//
//  BlankViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-04-23.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class BlankViewController: UIViewController {
    
    var emptyHomescreenView : EmptyHomescreenView!

    override func viewDidLoad() {
        super.viewDidLoad()

        /*self.emptyHomescreenView = EmptyHomescreenView.construct(self, title: "", description: "") as EmptyHomescreenView
        self.emptyHomescreenView.translatesAutoresizingMaskIntoConstraints = true
        self.emptyHomescreenView.arrowImageView.image = nil
        self.emptyHomescreenView.mainImageView.image = UIImage(named: "Gradcap_love")
        self.emptyHomescreenView.mainImageView.center.y = self.emptyHomescreenView.center.y
        self.view.addSubview(emptyHomescreenView)*/
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /*self.emptyHomescreenView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - self.navigationController!.navigationBar.frame.size.height - self.tabBarController!.tabBar.frame.size.height - UIApplication.shared.statusBarFrame.size.height)
        self.emptyHomescreenView.center.y = self.view.center.y*/
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
