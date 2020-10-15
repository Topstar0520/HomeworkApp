//
//  CustomTabBarViewController.swift
//  B4Grad
//
//  Created by Azeem Akram on 16/10/2018.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

class CustomTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func awakeFromNib() {
        if #available(iOS 13.0, *) {
            for tabBarItem in (self.tabBar.items)! {
                tabBarItem.imageInsets.top = 0
                tabBarItem.imageInsets.bottom = 0
                tabBarItem.imageInsets.left = 0
                tabBarItem.imageInsets.right = 0
            }
            
            if (UIDevice.current.userInterfaceIdiom == .phone) {
                for (index, tabBarItem) in (self.tabBar.items?.enumerated())! {
                    if (index == (self.tabBar.items!.count / 2)) { //centre item
                        tabBarItem.imageInsets.top = 5
                        tabBarItem.imageInsets.bottom = -5
                        tabBarItem.imageInsets.left = 0
                        tabBarItem.imageInsets.right = 0
                    }
                }
            }
            
        }
    }
    

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
        /*let navController = ((self.splitViewController?.viewControllers.count)! > 1) ? self.splitViewController?.viewControllers[1] : nil
        if (navController != nil) {
            if (navController!.isKind(of: UINavigationController.self)) {
                let nav = navController as! UINavigationController
                nav.viewControllers = []
            }
        }*/
    }
    

}
