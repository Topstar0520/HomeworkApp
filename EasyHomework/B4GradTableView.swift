//
//  B4GradTableView.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-21.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class B4GradTableView: UITableView { //For handling Selection/Deselection of cells without a selectedBackgroundView (by modifying views in the cell instead). For better troubleshooting, use print in all relevant methods and compare the print statements of two separate taskManagerVCs.
    
    override func deselectRow(at indexPath: IndexPath, animated: Bool) {
        let cell = self.cellForRow(at: indexPath) as? HomeworkTableViewCell
        if (animated == true) {
            cell?.cardView.backgroundColor = UIColor.white //use whichever view inside cell, in this case: cardView
        }
        super.deselectRow(at: indexPath, animated: animated)
    }
    
    override func selectRow(at indexPath: IndexPath?, animated: Bool, scrollPosition: UITableViewScrollPosition) {
        super.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        let cell = self.cellForRow(at: indexPath!) as? HomeworkTableViewCell
        if (animated == true) {
            //use whichever view inside cell, in this case: cardView
            cell?.cardView.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
