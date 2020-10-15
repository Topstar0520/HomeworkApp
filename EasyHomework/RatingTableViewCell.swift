//
//  RatingTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-27.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

// A protocol that the RatingTableViewCell uses to inform its delegate of state change
protocol RatingTableViewCellDelegate {
    func starRatingHasChanged(_ rating: Int)
}

class RatingTableViewCell: UITableViewCell {

    @IBOutlet var firstStarBtn: UIButton!
    @IBOutlet var secondStarBtn: UIButton!
    @IBOutlet var thirdStarBtn: UIButton!
    @IBOutlet var fourthStarBtn: UIButton!
    @IBOutlet var fifthStarBtn: UIButton!
    var delegate: RatingTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func firstStarBtnTapped(_ sender: AnyObject) {
        let starBtn = sender as! UIButton
        starBtn.isSelected = true
        secondStarBtn.isSelected = false
        thirdStarBtn.isSelected = false
        fourthStarBtn.isSelected = false
        fifthStarBtn.isSelected = false
        if (delegate != nil) {
            delegate!.starRatingHasChanged(1)
        }
    }
    
    @IBAction func secondStarBtnTapped(_ sender: AnyObject) {
        let starBtn = sender as! UIButton
        starBtn.isSelected = true
        firstStarBtn.isSelected = true
        thirdStarBtn.isSelected = false
        fourthStarBtn.isSelected = false
        fifthStarBtn.isSelected = false
        if (delegate != nil) {
            delegate!.starRatingHasChanged(2)
        }
    }
    
    @IBAction func thirdStarBtnTapped(_ sender: AnyObject) {
        let starBtn = sender as! UIButton
        starBtn.isSelected = true
        firstStarBtn.isSelected = true
        secondStarBtn.isSelected = true
        fourthStarBtn.isSelected = false
        fifthStarBtn.isSelected = false
        if (delegate != nil) {
            delegate!.starRatingHasChanged(3)
        }
    }
    
    @IBAction func fourthStarBtnTapped(_ sender: AnyObject) {
        let starBtn = sender as! UIButton
        starBtn.isSelected = true
        firstStarBtn.isSelected = true
        secondStarBtn.isSelected = true
        thirdStarBtn.isSelected = true
        fifthStarBtn.isSelected = false
        if (delegate != nil) {
            delegate!.starRatingHasChanged(4)
        }
    }
    
    @IBAction func fifthStarBtnTapped(_ sender: AnyObject) {
        let starBtn = sender as! UIButton
        starBtn.isSelected = true
        firstStarBtn.isSelected = true
        secondStarBtn.isSelected = true
        thirdStarBtn.isSelected = true
        fourthStarBtn.isSelected = true
        if (delegate != nil) {
            delegate!.starRatingHasChanged(5)
        }
    }
    
    func setStars(_ rating: Int) {
        firstStarBtn.isSelected = false
        secondStarBtn.isSelected = false
        thirdStarBtn.isSelected = false
        fourthStarBtn.isSelected = false
        fifthStarBtn.isSelected = false
        if (rating > 0) {
            firstStarBtn.isSelected = true
        }
        if (rating > 1) {
            secondStarBtn.isSelected = true
        }
        if (rating > 2) {
            thirdStarBtn.isSelected = true
        }
        if (rating > 3) {
            fourthStarBtn.isSelected = true
        }
        if (rating > 4) {
            fifthStarBtn.isSelected = true
        }
    }
    
}
