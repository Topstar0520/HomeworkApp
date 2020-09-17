//
//  B4GradViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-10.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class B4GradViewController: UIViewController {
    
    var b4GradTitleView : UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureTitleView()
    }
    
    func configureTitleView() {
        self.b4GradTitleView = UIImageView(image: UIImage(named: "Graduation Cap White"))
        b4GradTitleView.tintColor = UIColor.white
        b4GradTitleView.contentMode = UIViewContentMode.scaleAspectFit
        b4GradTitleView.frame.origin = CGPoint(x: 0, y: 0)
        b4GradTitleView.frame.size = CGSize(width: 45, height: 45)
        self.navigationItem.titleView = b4GradTitleView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //The code below handles the sizing of the UINavigationController's titleView.
        if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact) {
            self.b4GradTitleView.frame.size = CGSize(width: 35, height: 35)
        } else {
            self.b4GradTitleView.frame.size = CGSize(width: 45, height: 45)
        }
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
