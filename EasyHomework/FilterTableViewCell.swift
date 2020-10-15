//
//  FilterTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-22.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var filterButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.filterButton.setBackgroundImage(imageWithColor(UIColor(red: 255, green: 255, blue: 255, alpha: 0.05)), for: UIControlState())
        self.filterButton.setBackgroundImage(imageWithColor(UIColor(red: 255, green: 255, blue: 255, alpha: 0.16)), for: .highlighted)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
    
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
    
        let colorAsImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return colorAsImage!
    }

}
