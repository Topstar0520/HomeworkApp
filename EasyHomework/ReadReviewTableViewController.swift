//
//  ReadReviewTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-26.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import Parse

class ReadReviewTableViewController: UITableViewController {
    
    var review: PFObject!
    var tableContents = ["ThreeStarTableViewCell", "ReviewContentTableViewCell", "ReviewInfoCell"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableContents.removeFirst()
        self.tableContents.insert(generateIdentifier(), at: 0)
        
        self.tableView.estimatedRowHeight = 126
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        //print(review.objectForKey("rating") as? Int)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateIdentifier() -> String {
        var identifier = ""
        let rating = review.object(forKey: "rating") as? Int
        if (rating == 1) {
            identifier = "OneStarTableViewCell"
            return identifier
        } else if (rating == 2) {
            identifier = "TwoStarTableViewCell"
            return identifier
        } else if (rating == 3) {
            identifier = "ThreeStarTableViewCell"
            return identifier
        } else if (rating == 4) {
            identifier = "FourStarTableViewCell"
            return identifier
        } else if (rating == 5) {
            identifier = "FiveStarTableViewCell"
            return identifier
        } else {
            identifier = "ThreeStarTableViewCell"
            return identifier
        }
    }
    
    @IBAction func thumbsUpTapped(_ sender: AnyObject) {
        if let thumbsUpButton = sender as? UIButton {
            let buttonPosition = thumbsUpButton.convert(CGPoint.zero, to: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
            let cell = self.tableView.cellForRow(at: indexPath!) as! ReviewContentTableViewCell
            
            cell.thumbsDownButton.isSelected = false
            thumbsUpButton.isSelected = !thumbsUpButton.isSelected
        }
    }
    
    @IBAction func thumbsDownTapped(_ sender: AnyObject) {
        if let thumbsDownButton = sender as? UIButton {
            let buttonPosition = thumbsDownButton.convert(CGPoint.zero, to: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
            let cell = self.tableView.cellForRow(at: indexPath!) as! ReviewContentTableViewCell
            
            cell.thumbsUpButton.isSelected = false
            thumbsDownButton.isSelected = !thumbsDownButton.isSelected
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableContents.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellContent = self.tableContents[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellContent, for: indexPath)
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        if let oneStarCell = cell as? OneStarReviewTableViewCell {
            let emojiUnicode = review.object(forKey: "emoji") as? String
            if (emojiUnicode != nil) {
                let data = emojiUnicode!.data(using: String.Encoding.utf8)
                let emoji = String.init(data: data!, encoding: String.Encoding.nonLossyASCII)
                oneStarCell.emojiLabel.text = emoji
            } else {
                let emoji = "❓"
                oneStarCell.emojiLabel.text = emoji
            }
            let tags = review.object(forKey: "tags") as? [String]
            if (tags == nil) {
                return oneStarCell
            }
            for (index, tag) in tags!.enumerated() {
                if (index == 0) {
                    oneStarCell.tag1Label.text = tag
                    oneStarCell.tag1ImageView.image = UIImage(named: tag)
                }
                if (index == 1) {
                    oneStarCell.tag2Label.text = tag
                    oneStarCell.tag2ImageView.image = UIImage(named: tag)
                }
                if (index == 2) {
                    oneStarCell.tag3Label.text = tag
                    oneStarCell.tag3ImageView.image = UIImage(named: tag)
                }
            }
            if (tags!.count == 1) {
                oneStarCell.tag2View.removeConstraints(oneStarCell.tag2View.constraints)
                oneStarCell.tag2View.isHidden = true
                oneStarCell.tag3View.removeConstraints(oneStarCell.tag3View.constraints)
                oneStarCell.tag3View.isHidden = true
            }
            if (tags!.count == 2) {
                oneStarCell.tag3View.removeConstraints(oneStarCell.tag3View.constraints)
                oneStarCell.tag3View.isHidden = true
            }
            return oneStarCell
        }
        
        if let twoStarCell = cell as? TwoStarReviewTableViewCell {
            let emojiUnicode = review.object(forKey: "emoji") as? String
            if (emojiUnicode != nil) {
                let data = emojiUnicode!.data(using: String.Encoding.utf8)
                let emoji = String.init(data: data!, encoding: String.Encoding.nonLossyASCII)
                twoStarCell.emojiLabel.text = emoji
            } else {
                let emoji = "❓"
                twoStarCell.emojiLabel.text = emoji
            }
            let tags = review.object(forKey: "tags") as? [String]
            if (tags == nil) {
                return twoStarCell
            }
            for (index, tag) in tags!.enumerated() {
                if (index == 0) {
                    twoStarCell.tag1Label.text = tag
                    twoStarCell.tag1ImageView.image = UIImage(named: tag)
                }
                if (index == 1) {
                    twoStarCell.tag2Label.text = tag
                    twoStarCell.tag2ImageView.image = UIImage(named: tag)
                }
                if (index == 2) {
                    twoStarCell.tag3Label.text = tag
                    twoStarCell.tag3ImageView.image = UIImage(named: tag)
                }
            }
            if (tags!.count == 1) {
                twoStarCell.tag2View.removeConstraints(twoStarCell.tag2View.constraints)
                twoStarCell.tag2View.isHidden = true
                twoStarCell.tag3View.removeConstraints(twoStarCell.tag3View.constraints)
                twoStarCell.tag3View.isHidden = true
            }
            if (tags!.count == 2) {
                twoStarCell.tag3View.removeConstraints(twoStarCell.tag3View.constraints)
                twoStarCell.tag3View.isHidden = true
            }

            return twoStarCell
        }
        
        if let threeStarCell = cell as? ThreeStarReviewTableViewCell {
            let emojiUnicode = review.object(forKey: "emoji") as? String
            if (emojiUnicode != nil) {
                let data = emojiUnicode!.data(using: String.Encoding.utf8)
                let emoji = String.init(data: data!, encoding: String.Encoding.nonLossyASCII)
                threeStarCell.emojiLabel.text = emoji
            } else {
                let emoji = "❓"
                threeStarCell.emojiLabel.text = emoji
            }
            let tags = review.object(forKey: "tags") as? [String]
            if (tags == nil) {
                return threeStarCell
            }
            for (index, tag) in tags!.enumerated() {
                if (index == 0) {
                    threeStarCell.tag1Label.text = tag
                    threeStarCell.tag1ImageView.image = UIImage(named: tag)
                }
                if (index == 1) {
                    threeStarCell.tag2Label.text = tag
                    threeStarCell.tag2ImageView.image = UIImage(named: tag)
                }
                if (index == 2) {
                    threeStarCell.tag3Label.text = tag
                    threeStarCell.tag3ImageView.image = UIImage(named: tag)
                }
            }
            if (tags!.count == 1) {
                threeStarCell.tag2View.removeConstraints(threeStarCell.tag2View.constraints)
                threeStarCell.tag2View.isHidden = true
                threeStarCell.tag3View.removeConstraints(threeStarCell.tag3View.constraints)
                threeStarCell.tag3View.isHidden = true
            }
            if (tags!.count == 2) {
                threeStarCell.tag3View.removeConstraints(threeStarCell.tag3View.constraints)
                threeStarCell.tag3View.isHidden = true
            }

            return threeStarCell
        }
        
        if let fourStarCell = cell as? FourStarReviewTableViewCell {
            let emojiUnicode = review.object(forKey: "emoji") as? String
            if (emojiUnicode != nil) {
                let data = emojiUnicode!.data(using: String.Encoding.utf8)
                let emoji = String.init(data: data!, encoding: String.Encoding.nonLossyASCII)
                fourStarCell.emojiLabel.text = emoji
            } else {
                let emoji = "❓"
                fourStarCell.emojiLabel.text = emoji
            }
            let tags = review.object(forKey: "tags") as? [String]
            if (tags == nil) {
                return fourStarCell
            }
            for (index, tag) in tags!.enumerated() {
                if (index == 0) {
                    fourStarCell.tag1Label.text = tag
                    fourStarCell.tag1ImageView.image = UIImage(named: tag)
                }
                if (index == 1) {
                    fourStarCell.tag2Label.text = tag
                    fourStarCell.tag2ImageView.image = UIImage(named: tag)
                }
                if (index == 2) {
                    fourStarCell.tag3Label.text = tag
                    fourStarCell.tag3ImageView.image = UIImage(named: tag)
                }
            }
            if (tags!.count == 1) {
                fourStarCell.tag2View.removeConstraints(fourStarCell.tag2View.constraints)
                fourStarCell.tag2View.isHidden = true
                fourStarCell.tag3View.removeConstraints(fourStarCell.tag3View.constraints)
                fourStarCell.tag3View.isHidden = true
            }
            if (tags!.count == 2) {
                fourStarCell.tag3View.removeConstraints(fourStarCell.tag3View.constraints)
                fourStarCell.tag3View.isHidden = true
            }

            return fourStarCell
        }
        
        if let fiveStarCell = cell as? FiveStarReviewTableViewCell {
            let emojiUnicode = review.object(forKey: "emoji") as? String
            if (emojiUnicode != nil) {
                let data = emojiUnicode!.data(using: String.Encoding.utf8)
                let emoji = String.init(data: data!, encoding: String.Encoding.nonLossyASCII)
                fiveStarCell.emojiLabel.text = emoji
            } else {
                let emoji = "❓"
                fiveStarCell.emojiLabel.text = emoji
            }
            let tags = review.object(forKey: "tags") as? [String]
            if (tags == nil) {
                return fiveStarCell
            }
            for (index, tag) in tags!.enumerated() {
                if (index == 0) {
                    fiveStarCell.tag1Label.text = tag
                    fiveStarCell.tag1ImageView.image = UIImage(named: tag)
                }
                if (index == 1) {
                    fiveStarCell.tag2Label.text = tag
                    fiveStarCell.tag2ImageView.image = UIImage(named: tag)
                }
                if (index == 2) {
                    fiveStarCell.tag3Label.text = tag
                    fiveStarCell.tag3ImageView.image = UIImage(named: tag)
                }
            }
            if (tags!.count == 1) {
                fiveStarCell.tag2View.removeConstraints(fiveStarCell.tag2View.constraints)
                fiveStarCell.tag2View.isHidden = true
                fiveStarCell.tag3View.removeConstraints(fiveStarCell.tag3View.constraints)
                fiveStarCell.tag3View.isHidden = true
            }
            if (tags!.count == 2) {
                fiveStarCell.tag3View.removeConstraints(fiveStarCell.tag3View.constraints)
                fiveStarCell.tag3View.isHidden = true
            }

            return fiveStarCell
        }
        
        if let reviewContentCell = cell as? ReviewContentTableViewCell {
            let content = review.object(forKey: "content") as? String
            if (content == nil) {
                return reviewContentCell
            }
            reviewContentCell.contentLabel.text = content
            return reviewContentCell
        }
        
        if let infoCell = cell as? InfoTableViewCell {
            let user = review.object(forKey: "user") as? PFObject
            let userDisplayName = user?.object(forKey: "displayName") as? String
            if (userDisplayName == nil) {
                return infoCell
            }
            infoCell.usernameLabel.text = userDisplayName
            var seasonString = ""
            let date = review.updatedAt
            if (date == nil) {
                return infoCell
            }
            let calendar = Calendar.current
            let components = (calendar as NSCalendar).components([NSCalendar.Unit.month, NSCalendar.Unit.year], from: date!)
            if (components.month! >= 1 && components.month! <= 4) {
                seasonString += ("Spring " + String(components.year!))
            } else if (components.month! >= 5 && components.month! <= 8) {
                seasonString += ("Summer " + String(components.year!))
            } else  if (components.month! >= 9 && components.month! <= 12) {
                seasonString += ("Winter " + String(components.year!))
            }
            infoCell.semesterAndDateLabel.text = seasonString
            let upVotes = review.object(forKey: "upVotes") as? Int
            let downVotes = review.object(forKey: "downVotes") as? Int
            if (upVotes == nil || downVotes == nil) {
                infoCell.feedbackLabel.text = "No Feedback Found."
                return infoCell
            }
            if (upVotes == 0 && downVotes == 0) {
                infoCell.feedbackLabel.text = "No Feedback Found."
                return infoCell
            }
            let totalVotes = upVotes! - downVotes!
            if (totalVotes < -1) {
                infoCell.feedbackLabel.text = "Most Students found this review unhelpful."
            }
            if (totalVotes == 0 || totalVotes == -1 || totalVotes == 1) {
                infoCell.feedbackLabel.text = "Students are mixed about this review."
            }
            if (totalVotes > 1) {
                infoCell.feedbackLabel.text = "Most Students found this review helpful."
            }
            
            return infoCell
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
