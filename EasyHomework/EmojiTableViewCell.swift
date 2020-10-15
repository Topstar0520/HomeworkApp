//
//  EmojiTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-27.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

// A protocol that the RatingTableViewCell uses to inform its delegate of state change
protocol EmojiTableViewCellDelegate {
    func emojiSelectionHasChanged(_ selectedEmoji: Int?)
}

import UIKit

class EmojiTableViewCell: UITableViewCell {

    @IBOutlet var firstEmojiButton: UIButton!
    @IBOutlet var secondEmojiButton: UIButton!
    @IBOutlet var thirdEmojiButton: UIButton!
    @IBOutlet var fourthEmojiButton: UIButton!
    @IBOutlet var firstCheckmarkImageView: UIImageView!
    @IBOutlet var secondCheckmarkImageView: UIImageView!
    @IBOutlet var thirdCheckmarkImageView: UIImageView!
    @IBOutlet var fourthCheckmarkImageView: UIImageView!
    var delegate: EmojiTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func firstEmojiTapped(_ sender: AnyObject) {
        //let emojiBtn = sender as! UIButton
        //emojiBtn.selected = true
        //secondEmojiButton.selected = false
        //thirdEmojiButton.selected = false
        //fourthEmojiButton.selected = false
        if (firstEmojiButton.titleLabel!.text == "❓") {
            return
        }
        firstCheckmarkImageView.isHidden = false
        secondCheckmarkImageView.isHidden = true
        thirdCheckmarkImageView.isHidden = true
        fourthCheckmarkImageView.isHidden = true
        delegate?.emojiSelectionHasChanged(1)
    }
    
    @IBAction func secondEmojiTapped(_ sender: AnyObject) {
        //let emojiBtn = sender as! UIButton
        //emojiBtn.selected = true
        //firstEmojiButton.selected = false
        //thirdEmojiButton.selected = false
        //fourthEmojiButton.selected = false
        if (firstEmojiButton.titleLabel!.text == "❓") {
            return
        }
        firstCheckmarkImageView.isHidden = true
        secondCheckmarkImageView.isHidden = false
        thirdCheckmarkImageView.isHidden = true
        fourthCheckmarkImageView.isHidden = true
        delegate?.emojiSelectionHasChanged(2)
    }
    
    @IBAction func thirdEmojiTapped(_ sender: AnyObject) {
        /*let emojiBtn = sender as! UIButton
        emojiBtn.selected = true
        firstEmojiButton.selected = false
        secondEmojiButton.selected = false
        fourthEmojiButton.selected = false*/
        if (firstEmojiButton.titleLabel!.text == "❓") {
            return
        }
        firstCheckmarkImageView.isHidden = true
        secondCheckmarkImageView.isHidden = true
        thirdCheckmarkImageView.isHidden = false
        fourthCheckmarkImageView.isHidden = true
        delegate?.emojiSelectionHasChanged(3)
    }
    
    @IBAction func fourthEmojiTapped(_ sender: AnyObject) {
        /*let emojiBtn = sender as! UIButton
        emojiBtn.selected = true
        firstEmojiButton.selected = false
        secondEmojiButton.selected = false
        thirdEmojiButton.selected = false*/
        if (firstEmojiButton.titleLabel!.text == "❓") {
            return
        }
        firstCheckmarkImageView.isHidden = true
        secondCheckmarkImageView.isHidden = true
        thirdCheckmarkImageView.isHidden = true
        fourthCheckmarkImageView.isHidden = false
        delegate?.emojiSelectionHasChanged(4)
    }
    
    func setEmojis(_ currentRating: Int) {
        if (currentRating == 0) {
            firstEmojiButton.setTitle("❓", for: UIControlState())
            secondEmojiButton.setTitle("❓", for: UIControlState())
            thirdEmojiButton.setTitle("❓", for: UIControlState())
            fourthEmojiButton.setTitle("❓", for: UIControlState())
        }
        if (currentRating == 1) {
            firstEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 1), for: UIControlState())
            secondEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 2), for: UIControlState())
            thirdEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 3), for: UIControlState())
            fourthEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 4), for: UIControlState())
        }
        if (currentRating == 2) {
            firstEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 1), for: UIControlState())
            secondEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 2), for: UIControlState())
            thirdEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 3), for: UIControlState())
            fourthEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 4), for: UIControlState())
        }
        if (currentRating == 3) {
            firstEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 1), for: UIControlState())
            secondEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 2), for: UIControlState())
            thirdEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 3), for: UIControlState())
            fourthEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 4), for: UIControlState())
        }
        if (currentRating == 4) {
            firstEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 1), for: UIControlState())
            secondEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 2), for: UIControlState())
            thirdEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 3), for: UIControlState())
            fourthEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 4), for: UIControlState())
        }
        if (currentRating == 5) {
            firstEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 1), for: UIControlState())
            secondEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 2), for: UIControlState())
            thirdEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 3), for: UIControlState())
            fourthEmojiButton.setTitle(EmojiDataModel.emojiForRating(currentRating, selectedEmojiNumber: 4), for: UIControlState())
        }
    }
    
    func selectEmoji(_ value: Int?) {
        if (value == nil) {
            self.deselectEmoji()
            delegate?.emojiSelectionHasChanged(nil)
        } else {
            if (value == 1) {
                firstCheckmarkImageView.isHidden = false
                secondCheckmarkImageView.isHidden = true
                thirdCheckmarkImageView.isHidden = true
                fourthCheckmarkImageView.isHidden = true
                delegate?.emojiSelectionHasChanged(1)
            }
            
            if (value == 2) {
                firstCheckmarkImageView.isHidden = true
                secondCheckmarkImageView.isHidden = false
                thirdCheckmarkImageView.isHidden = true
                fourthCheckmarkImageView.isHidden = true
                delegate?.emojiSelectionHasChanged(2)
            }
            
            if (value == 3) {
                firstCheckmarkImageView.isHidden = true
                secondCheckmarkImageView.isHidden = true
                thirdCheckmarkImageView.isHidden = false
                fourthCheckmarkImageView.isHidden = true
                delegate?.emojiSelectionHasChanged(3)
            }
            
            if (value == 4) {
                firstCheckmarkImageView.isHidden = true
                secondCheckmarkImageView.isHidden = true
                thirdCheckmarkImageView.isHidden = true
                fourthCheckmarkImageView.isHidden = false
                delegate?.emojiSelectionHasChanged(4)
            }
        }
    }
    
    func deselectEmoji() {
        firstCheckmarkImageView.isHidden = true
        secondCheckmarkImageView.isHidden = true
        thirdCheckmarkImageView.isHidden = true
        fourthCheckmarkImageView.isHidden = true
        delegate?.emojiSelectionHasChanged(nil)
    }
    
}
