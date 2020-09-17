//
//  WriteReviewTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-27.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import Parse

class WriteReviewTableViewController: UITableViewController, RatingTableViewCellDelegate, EmojiTableViewCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {
    
    var tableContents :[Int:Array<WriteReviewRowContent>] = [0 : [WriteReviewRowContent(identifier: "DescribeExperiencesCell")], 1 : [WriteReviewRowContent(identifier: "RatingCell")], 2 : [WriteReviewRowContent(identifier: "EmojiCell")], 3 : [WriteReviewRowContent(identifier: "TagSelectionCell")], 4 : [WriteReviewRowContent(identifier: "ContentCell")], 5 : [WriteReviewRowContent(identifier: "ReviewButtonCell")] ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableContents.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableContents[section]!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellContent = self.tableContents[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellContent.identifier, for: indexPath)
        
        if (cellContent.identifier == "RatingCell") {
            let ratingCell = cell as! RatingTableViewCell
            ratingCell.delegate = self
            ratingCell.setStars(cellContent.rating)
        }
        
        if (cellContent.identifier == "EmojiCell") {
            let emojiCell = cell as! EmojiTableViewCell
            emojiCell.delegate = self
            let ratingCellContent = self.tableContents[1]![0]
            emojiCell.setEmojis(ratingCellContent.rating)
            emojiCell.selectEmoji(cellContent.selectedEmoji)
        }
        
        if (cellContent.identifier == "TagSelectionCell") {
            let tagSelectionCell = cell as! TagSelectionTableViewCell
            tagSelectionCell.collectionView.dataSource = self
            tagSelectionCell.collectionView.delegate = self
            tagSelectionCell.collectionView.reloadData()
            /*if (selectedTagsIndexPaths.count != 0) {
                for indexPath in selectedTagsIndexPaths {
                    tagSelectionCell.collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                    self.collectionView(tagSelectionCell.collectionView, didSelectItemAtIndexPath: indexPath)
                }
            }*/
        }
        
        if (cellContent.identifier == "ContentCell") {
            let writeReviewContentCell = cell as! WriteReviewContentTableViewCell
            writeReviewContentCell.contentTextView.delegate = self
            writeReviewContentCell.contentTextView.text = cellContent.contentString
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellContent = self.tableContents[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row]
        let cell = tableView.cellForRow(at: indexPath)!
        if (cellContent.identifier == "ReviewButtonCell") {
            self.tableView.deselectRow(at: indexPath, animated: true)
            cell.isUserInteractionEnabled = false
            
            let rating = self.tableContents[1]![0].rating
            
            let selectedEmojiNumber = self.tableContents[2]![0].selectedEmoji
            let emojiString = EmojiDataModel.emojiForRating(rating, selectedEmojiNumber: selectedEmojiNumber)
            let emojiStringData = emojiString.data(using: String.Encoding.nonLossyASCII)
            let emojiUnicodeString = NSString(data: emojiStringData!, encoding: String.Encoding.utf8.rawValue)!
            
            var tags = [String]()
            for indexPath in self.selectedTagsIndexPaths {
                tags.append(self.tagsCollection[(indexPath as NSIndexPath).row])
            }
            
            var content = self.tableContents[4]![0].contentString
            if (content == nil) {
                content = ""
            }
            //Insert code here to actually verify that all required information was filled in first. (E.x., rating was set, emoji selected, etc.)
            
            let courseQuery = PFQuery(className: "Course")
            courseQuery.whereKey("courseCode", equalTo: "CS2209")
            courseQuery.getFirstObjectInBackground(block: { (course, error) -> Void in
                if (error == nil) {
                    let review = PFObject(className: "Review")
                    review.setObject(course!, forKey: "course")
                    review.setObject(rating, forKey: "rating")
                    review.setObject(emojiUnicodeString, forKey: "emoji")
                    review.setObject(tags, forKey: "tags")
                    review.setObject(content, forKey: "content")
                    //review.setObject(<#T##object: AnyObject##AnyObject#>, forKey: "professor")
                    //review.setObject(<#T##object: AnyObject##AnyObject#>, forKey: "section")
                    //review.setObject(<#T##object: AnyObject##AnyObject#>, forKey: "season")
                    review.saveInBackground(block: { (success, error) -> Void in
                        if (error == nil) {
                            self.navigationController!.popViewController(animated: true)
                        } else {
                            cell.isUserInteractionEnabled = true
                            let errorVC = UIAlertController(title: "Oops..", message: error?.localizedDescription, preferredStyle: .alert)
                            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                            self.present(errorVC, animated: true, completion: nil)
                        }
                    })
                    
                } else {
                    cell.isUserInteractionEnabled = true
                    let errorVC = UIAlertController(title: "Oops..", message: error?.localizedDescription, preferredStyle: .alert)
                    errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                    self.present(errorVC, animated: true, completion: nil)
                }
                
            })
            
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 21/255, green: 21/255, blue: 21/255, alpha: 1.0)
        if (cell.contentView.backgroundColor != UIColor.clear) {
            cell.backgroundColor = cell.contentView.backgroundColor
        }
    }
    
    var tagCollectionViewHeight : CGFloat?
    var viewWillAppearOccurred = false
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellContent = self.tableContents[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row]
        if (cellContent.identifier == "DescribeExperiencesCell") {
            return 107
        }
        if (cellContent.identifier == "TagSelectionCell") {
            if (tagCollectionViewHeight != nil) {
                return tagCollectionViewHeight!
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "TagSelectionCell") as! TagSelectionTableViewCell
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            if (self.traitCollection.verticalSizeClass == .compact) {
                //Compact vertical class causes last row to be cut off.
                return cell.collectionView.collectionViewLayout.collectionViewContentSize.height + 50
            }
            return cell.collectionView.collectionViewLayout.collectionViewContentSize.height + 15
        }
        return UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (viewWillAppearOccurred == false) {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? TagSelectionTableViewCell
            if (cell != nil) {
                tagCollectionViewHeight = cell!.collectionView.collectionViewLayout.collectionViewContentSize.height + 15
                if (UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation == .portrait) {
                    tagCollectionViewHeight! += 50
                }
                self.tableView.reloadSections(IndexSet(integer: 3), with: .none)
            }
        }
        viewWillAppearOccurred = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? TagSelectionTableViewCell
        if (cell != nil) {
            tagCollectionViewHeight = cell!.collectionView.collectionViewLayout.collectionViewContentSize.height + 15
            if (UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation == .portrait) {
                tagCollectionViewHeight! += 50
            }
            self.tableView.reloadSections(IndexSet(integer: 3), with: .none)
        }
    }
    
    var headersArray = ["Rate your Experience.", "Select an Emoji.", "Select up to 3 Tags. (0/3)", "Write your Review."]

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 1) {
            let headerView = SectionHeaderView.construct(headersArray[0], owner: tableView)
            return headerView
        }
        if (section == 2) {
            let headerView = SectionHeaderView.construct(headersArray[1], owner: tableView)
            return headerView
        }
        
        if (section == 3) {
            let headerView = SectionHeaderView.construct(headersArray[2], owner: tableView)
            return headerView
        }
        
        if (section == 4) {
            let headerView = SectionHeaderView.construct(headersArray[3], owner: tableView)
            return headerView
        }
        
        let invisView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        invisView.contentView.backgroundColor = UIColor.clear
        return invisView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 5) {
            return CGFloat.leastNormalMagnitude
        }
        if (section == 0) {
            return CGFloat.leastNormalMagnitude
        }
        return 21.0
    }
    
    func starRatingHasChanged(_ rating: Int) {
        let ratingContent = self.tableContents[1]![0]
        ratingContent.rating = rating
        let emojiCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! EmojiTableViewCell
        emojiCell.setEmojis(rating)
        
        //Deselect Emoji
        let emojiContent = self.tableContents[2]![0]
        emojiContent.selectedEmoji = nil
        emojiCell.deselectEmoji()
    }
    
    func emojiSelectionHasChanged(_ selectedEmoji: Int?) {
        let emojiContent = self.tableContents[2]![0]
        emojiContent.selectedEmoji = selectedEmoji
    }
    
    //UICollectionViewDataSource (for TagSelectionCell)
    //Note: This implementation relies on selectedTagesIndexPaths instead of the built-in collectionView selectedIndexPaths() method.
    
    let tagsCollection = ["Bird", "Dry", "Essential", "Fun", "GetBook", "Groupwork", "NoFinal", "Organized", "Zzz", "2Midterms"]
    var selectedTagsIndexPaths = [IndexPath]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellContent = tagsCollection[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectTagCollectionViewCell", for: indexPath) as! SelectTagCollectionViewCell
        cell.tagIconImageView.image = UIImage(named: cellContent)
        cell.tagLabel.text = cellContent
        
        if (selectedTagsIndexPaths.contains(indexPath)) {
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.20)
            cell.borderView.layer.borderWidth = 1
            cell.borderView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            cell.tagLabel.textColor = UIColor.white
            cell.isUserInteractionEnabled = true
        } else {
            if (selectedTagsIndexPaths.count == 3) {
                cell.tagLabel.textColor = UIColor.white.withAlphaComponent(0.45)
                cell.isUserInteractionEnabled = false
            }
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.07)
            cell.borderView.layer.borderWidth = 0
        }
        
        return cell
    }
    
    //UICollectionViewDelegate (for TagSelectionCell)
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let cellContent = tagsCollection[(indexPath as NSIndexPath).row]
        let label = UILabel()
        label.text = cellContent
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.sizeToFit()
        return CGSize(width: label.frame.width + 30 + 15, height: 25) //35 is width of UIImageView, 12 is the padding from leading/trailing constraints.
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        //if (selectedTagsIndexPaths.count >= 3) {
        //    return false
        //}
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (!selectedTagsIndexPaths.contains(indexPath) && selectedTagsIndexPaths.count < 3) {
            let cell = collectionView.cellForItem(at: indexPath)! as! SelectTagCollectionViewCell
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.20)
            cell.borderView.layer.borderWidth = 1
            cell.borderView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            if (!selectedTagsIndexPaths.contains(indexPath)) {
                selectedTagsIndexPaths.append(indexPath)
            }
            let numberOfSelectedItems = selectedTagsIndexPaths.count
            self.headersArray[2] = "Select up to 3 Tags. (" + String(numberOfSelectedItems) + "/3)"
            (self.tableView.headerView(forSection: 3) as! SectionHeaderView).titleLabel.text = headersArray[2]
            
            if (numberOfSelectedItems == 3) {
                self.setOtherCellsToBecomeDisabled(collectionView)
            }
        } else {
            collectionView.delegate!.collectionView!(collectionView, didDeselectItemAt: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)! as! SelectTagCollectionViewCell
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        cell.borderView.layer.borderWidth = 0
        selectedTagsIndexPaths.removeObject(object: indexPath)
        let numberOfSelectedItems = selectedTagsIndexPaths.count
        self.headersArray[2] = "Select up to 3 Tags. (" + String(numberOfSelectedItems) + "/3)"
        (self.tableView.headerView(forSection: 3) as! SectionHeaderView).titleLabel.text = headersArray[2]
        
        let maxNumberOfSelectableItems = 3
        if (numberOfSelectedItems >= maxNumberOfSelectableItems - 1) {
            self.setOtherCellsToBecomeEnabled(collectionView)
        }
    }
    
    func setOtherCellsToBecomeDisabled(_ collectionView: UICollectionView) {
        for cell in collectionView.visibleCells {
            if (!selectedTagsIndexPaths.contains(collectionView.indexPath(for: cell)!)) {
                let tagCell = cell as! SelectTagCollectionViewCell
                tagCell.tagLabel.textColor = UIColor.white.withAlphaComponent(0.45)
                tagCell.isUserInteractionEnabled = false
            }
        }
    }
    
    func setOtherCellsToBecomeEnabled(_ collectionView: UICollectionView) {
        for cell in collectionView.visibleCells {
            if (!selectedTagsIndexPaths.contains(collectionView.indexPath(for: cell)!)) {
                let tagCell = cell as! SelectTagCollectionViewCell
                tagCell.tagLabel.textColor = UIColor.white
                tagCell.isUserInteractionEnabled = true
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.tableContents[4]![0].contentString = textView.text
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
