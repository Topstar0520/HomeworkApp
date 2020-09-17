//
//  SchedulesViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-20.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import Parse

class SchedulesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource {

    @IBOutlet var tableView: UITableView!
    var dataArray = [CellDataObject(identifier: "Intro"), CellDataObject(identifier: "Reviews"), CellDataObject(identifier: "Filter")]
    var schedulesArray = [CellDataObject(identifier: "Schedule"), CellDataObject(identifier: "Schedule"), CellDataObject(identifier: "Schedule")]
    var selectedCourse: CourseResult!
    let reviewsQuery = PFQuery(className: "Review")
    var reviewsLoadingProgress = loadProgress.loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.clear
        
        let backgroundImageView = UIImageView(image: UIImage(named: "studentsoutside2"))
        backgroundImageView.frame = self.view.frame
        backgroundImageView.contentMode = .scaleAspectFill
        self.view.addSubview(backgroundImageView)
        let blackOverlay = UIView(frame: CGRect(x: 0, y: 0, width: 2000, height: 2000))
        blackOverlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        backgroundImageView.addSubview(blackOverlay)
        self.tableView.backgroundView = backgroundImageView

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 192
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        reviewsQuery.whereKey("course", equalTo: selectedCourse.coursePFObject)
        reviewsQuery.includeKey("user")
        reviewsQuery.limit = 15
        reviewsQuery.order(byDescending: "updatedAt")
        reviewsQuery.addDescendingOrder("upVotes")
        reviewsQuery.findObjectsInBackground(block: {(reviews, error) -> Void in
            if (error == nil) {
                self.reviewsData = reviews!
                self.reviewsLoadingProgress = loadProgress.successful
                if let reviewsCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ReviewsTableViewCell {
                    reviewsCell.collectionView.reloadData()
                    reviewsCell.refreshIndicator.stopAnimating()
                    if (self.reviewsData.count == 0 || reviews == nil) {
                        UIView.animate(withDuration: 0.1, delay: 0.0, options: [UIViewAnimationOptions.allowUserInteraction, UIViewAnimationOptions.curveEaseIn], animations: { reviewsCell.noReviewsLabel.alpha = 1.0 }, completion: nil)
                    } else {
                        UIView.animate(withDuration: 0.1, delay: 0.0, options: [UIViewAnimationOptions.allowUserInteraction, UIViewAnimationOptions.curveEaseIn], animations: { reviewsCell.collectionView.alpha = 1.0 }, completion: nil)
                    }
                }
            } else {
                self.reviewsLoadingProgress = loadProgress.error
                if let reviewsCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ReviewsTableViewCell {
                    reviewsCell.refreshIndicator.stopAnimating()
                    reviewsCell.noReviewsLabel.text = "Reviews Not Found"
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: [UIViewAnimationOptions.allowUserInteraction, UIViewAnimationOptions.curveEaseIn], animations: { reviewsCell.noReviewsLabel.alpha = 1.0 }, completion: nil)
                }
                let errorVC = UIAlertController(title: "Oops..", message: error?.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
        })
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let selectedRowIndexPath = self.tableView.indexPathForSelectedRow
        if ((selectedRowIndexPath) != nil) {
            self.tableView.deselectRow(at: selectedRowIndexPath!, animated: true)
            /*self.transitionCoordinator()?.notifyWhenInteractionEndsUsingBlock({ context in
                if (context.isCancelled()) {
                    self.tableView.selectRowAtIndexPath(selectedRowIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                }
            })*/
        }
        
        if let reviewsCell = self.tableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? ReviewsTableViewCell {
            let selectedCellIndexPaths = reviewsCell.collectionView.indexPathsForSelectedItems
            if (selectedCellIndexPaths!.count != 0) {
                reviewsCell.collectionView.deselectItem(at: selectedCellIndexPaths!.first!, animated: true)
                self.transitionCoordinator?.notifyWhenInteractionEnds({ context in
                    if (context.isCancelled) {
                        reviewsCell.collectionView.selectItem(at: selectedCellIndexPaths!.first!, animated: false, scrollPosition: UICollectionViewScrollPosition())
                    }
                })
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.reviewsQuery.cancel()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return self.dataArray.count
        } else {
            return self.schedulesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellContent = self.dataArray[(indexPath as NSIndexPath).row]
        if ((indexPath as NSIndexPath).section == 0) {
            if (cellContent.identifier == "Intro") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CourseIntroTableViewCell", for: indexPath) as! CourseIntroTableViewCell
                cell.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                cell.backgroundColor = UIColor.clear
                cell.topImageView.image = UIImage(named: selectedCourse.faculty)
                cell.courseCodeLabel.text = selectedCourse.courseCode + " - " + selectedCourse.courseName
                return cell
            }
        
            if (cellContent.identifier == "Reviews") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewsTableViewCell", for: indexPath) as! ReviewsTableViewCell
                cell.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                cell.backgroundColor = UIColor.clear
                if (self.reviewsLoadingProgress == loadProgress.loading) {
                    cell.noReviewsLabel.alpha = 0.0
                    cell.collectionView.alpha = 0.0
                    cell.refreshIndicator.startAnimating()
                } else if (self.reviewsLoadingProgress == loadProgress.error) {
                    cell.refreshIndicator.stopAnimating()
                    cell.noReviewsLabel.text = "Reviews Not Found"
                    cell.noReviewsLabel.alpha = 1.0
                    cell.collectionView.alpha = 0.0
                } else if (self.reviewsLoadingProgress == loadProgress.successful) {
                    if (self.reviewsData.count == 0) {
                        cell.refreshIndicator.stopAnimating()
                        cell.collectionView.alpha = 0.0
                        cell.noReviewsLabel.alpha = 1.0
                    } else {
                        cell.refreshIndicator.stopAnimating()
                        cell.collectionView.reloadData()
                        cell.noReviewsLabel.alpha = 0.0
                        cell.collectionView.alpha = 1.0
                    }
                }
                return cell
            }
        
            if (cellContent.identifier == "Filter") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell", for: indexPath) as! FilterTableViewCell
                cell.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                cell.backgroundColor = UIColor.clear
                cell.filterButton.layer.cornerRadius = cell.filterButton.frame.size.width / 9
                cell.filterButton.layer.masksToBounds = true
                cell.descriptionLabel.text = "Schedules made by students in " + selectedCourse.courseCode + " are listed below. You may choose to use one of their schedules, or create your own."
                return cell
            }
        }
        
        if ((indexPath as NSIndexPath).section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as! ScheduleTableViewCell
            cell.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            cell.backgroundColor = UIColor.clear
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 1) {
            let reviewsHeaderCell = tableView.dequeueReusableCell(withIdentifier: "SchedulesHeaderView")! as UITableViewCell
            reviewsHeaderCell.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            reviewsHeaderCell.backgroundColor = UIColor.clear
            return reviewsHeaderCell
        }
        let invisView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        invisView.backgroundColor = UIColor.clear
        return invisView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return CGFloat.leastNormalMagnitude
        } else {
            return 21.0
        }
    }
    
    /* Data Source of ReviewCollectionViewCell */
    
    var reviewsData = [PFObject]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviewsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let review = self.reviewsData[(indexPath as NSIndexPath).item]
        var identifier: String!
        let numberOfStars = review.object(forKey: "rating") as? Int
        if (numberOfStars == 1) {
            identifier = "OneStarReviewCollectionViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! OneStarReviewCollectionViewCell
            let emojiUnicode = review.object(forKey: "emoji") as? String
            if (emojiUnicode != nil) {
                let data = emojiUnicode!.data(using: String.Encoding.utf8)
                let emoji = String.init(data: data!, encoding: String.Encoding.nonLossyASCII)
                cell.emojiLabel.text = emoji
            } else {
                let emoji = "❓"
                cell.emojiLabel.text = emoji
            }
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12)
            cell.selectedBackgroundView = selectedBackgroundView
            cell.layer.cornerRadius = cell.frame.size.width / 12
            cell.layer.masksToBounds = true
            return cell
        } else if (numberOfStars == 2) {
            identifier = "TwoStarReviewCollectionViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! TwoStarReviewCollectionViewCell
            let emojiUnicode = review.object(forKey: "emoji") as? String
            if (emojiUnicode != nil) {
                let data = emojiUnicode!.data(using: String.Encoding.utf8)
                let emoji = String.init(data: data!, encoding: String.Encoding.nonLossyASCII)
                cell.emojiLabel.text = emoji
            } else {
                let emoji = "❓"
                cell.emojiLabel.text = emoji
            }
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12)
            cell.selectedBackgroundView = selectedBackgroundView
            cell.layer.cornerRadius = cell.frame.size.width / 12
            cell.layer.masksToBounds = true
            return cell
        } else if (numberOfStars == 3) {
            identifier = "ThreeStarReviewCollectionViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ThreeStarReviewCollectionViewCell
            let emojiUnicode = review.object(forKey: "emoji") as? String
            if (emojiUnicode != nil) {
                let data = emojiUnicode!.data(using: String.Encoding.utf8)
                let emoji = String.init(data: data!, encoding: String.Encoding.nonLossyASCII)
                cell.emojiLabel.text = emoji
            } else {
                let emoji = "❓"
                cell.emojiLabel.text = emoji
            }
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12)
            cell.selectedBackgroundView = selectedBackgroundView
            cell.layer.cornerRadius = cell.frame.size.width / 12
            cell.layer.masksToBounds = true
            return cell
        } else if (numberOfStars == 4) {
            identifier = "FourStarReviewCollectionViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! FourStarReviewCollectionViewCell
            let emojiUnicode = review.object(forKey: "emoji") as? String
            if (emojiUnicode != nil) {
                let data = emojiUnicode!.data(using: String.Encoding.utf8)
                let emoji = String.init(data: data!, encoding: String.Encoding.nonLossyASCII)
                cell.emojiLabel.text = emoji
            } else {
                let emoji = "❓"
                cell.emojiLabel.text = emoji
            }
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12)
            cell.selectedBackgroundView = selectedBackgroundView
            cell.layer.cornerRadius = cell.frame.size.width / 12
            cell.layer.masksToBounds = true
            return cell
        } else if (numberOfStars == 5) {
            identifier = "FiveStarReviewCollectionViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! FiveStarReviewCollectionViewCell
            let emojiUnicode = review.object(forKey: "emoji") as? String
            if (emojiUnicode != nil) {
                let data = emojiUnicode!.data(using: String.Encoding.utf8)
                let emoji = String.init(data: data!, encoding: String.Encoding.nonLossyASCII)
                cell.emojiLabel.text = emoji
            } else {
                let emoji = "❓"
                cell.emojiLabel.text = emoji
            }
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12)
            cell.selectedBackgroundView = selectedBackgroundView
            cell.layer.cornerRadius = cell.frame.size.width / 12
            cell.layer.masksToBounds = true
            return cell
        } else if (numberOfStars == nil) {
            identifier = "ThreeStarReviewCollectionViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ThreeStarReviewCollectionViewCell
            let emojiUnicode = review.object(forKey: "emoji") as? String
            if (emojiUnicode != nil) {
                let data = emojiUnicode!.data(using: String.Encoding.utf8)
                let emoji = String.init(data: data!, encoding: String.Encoding.nonLossyASCII)
                cell.emojiLabel.text = emoji
            } else {
                let emoji = "❓"
                cell.emojiLabel.text = emoji
            }
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12)
            cell.selectedBackgroundView = selectedBackgroundView
            cell.layer.cornerRadius = cell.frame.size.width / 12
            cell.layer.masksToBounds = true
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reviewsHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ReviewCollectionReusableView", for: indexPath) as! ReviewCollectionReusableView
        reviewsHeaderView.reviewLabel.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        reviewsHeaderView.layer.cornerRadius = reviewsHeaderView.frame.size.width / 12
        reviewsHeaderView.layer.masksToBounds = true
        
        return reviewsHeaderView
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.destination is ScheduleEditorViewController) {
            if (sender is UIBarButtonItem) {
                //Modify the scheduleEditorVC accordingly.
                
            }
        }
        
        if (segue.destination is ReadReviewTableViewController) {
            let reviewCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! ReviewsTableViewCell
            let readReviewVC = segue.destination as! ReadReviewTableViewController
            let indexPath = reviewCell.collectionView.indexPathsForSelectedItems?.first!
            readReviewVC.review = self.reviewsData[((indexPath as NSIndexPath?)?.row)!]
        }
        
    }
    

}
