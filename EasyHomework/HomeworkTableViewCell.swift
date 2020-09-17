//
//  HomeworkTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-14.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol HomeworkTableViewCellDelegate {
    // indicates that the given item has been deleted
    func taskDeleted(_ task: RLMTask)
    // indicates that the given item has been completed
    func taskCompleted(_ task: RLMTask)
    // indicates that the given item should be moved
    func moveTask(_ cell: HomeworkTableViewCell, _ task: RLMTask)
}

class HomeworkTableViewCell: UITableViewCell {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var colorView: CircleView!
    @IBOutlet var facultyImageView: UIImageView!
    @IBOutlet var homeworkImageView: UIImageView!
    @IBOutlet var leadingCompletionConstraint: NSLayoutConstraint!
    @IBOutlet var completionImageView: SpringImageView!
    @IBOutlet var deletionImageView: SpringImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var courseLabel: UILabel!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var cardView: CardView!
    @IBOutlet var repeatsImageView: UIImageView!
    
    var recognizer: UIPanGestureRecognizer!
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var completeOnDrag = false
    var closeToCompleteOnDrag = false
    // The object that acts as delegate for this cell.
    var delegate: HomeworkTableViewCellDelegate?
    // The item that this cell renders.
    var task: RLMTask?
    
    var originalAlpha: CGFloat!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.recognizer = UIPanGestureRecognizer(target: self, action: #selector(HomeworkTableViewCell.handlePan(_:)))
        self.recognizer.delegate = self
        addGestureRecognizer(self.recognizer)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cardView.layer.masksToBounds = false
        self.layer.masksToBounds = false
        self.contentView.layer.masksToBounds = false
        
        self.completionImageView.layer.masksToBounds = false
        self.completionImageView.layer.shadowColor = UIColor.black.cgColor
        self.completionImageView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.completionImageView.layer.shadowOpacity = 0.25
        self.completionImageView.layer.shouldRasterize = true
        self.completionImageView.layer.rasterizationScale = UIScreen.main.scale
        
        self.deletionImageView.layer.masksToBounds = false
        self.deletionImageView.layer.shadowColor = UIColor.black.cgColor
        self.deletionImageView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.deletionImageView.layer.shadowOpacity = 0.25
        self.deletionImageView.layer.shouldRasterize = true
        self.deletionImageView.layer.rasterizationScale = UIScreen.main.scale
        
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cardView.layoutIfNeeded() //Needed for iOS10 since layoutSubviews() reports inaccurate frame sizes.
        self.cardView.layer.cornerRadius = self.cardView.frame.size.height / 3
        self.cardView.layer.masksToBounds = false
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.leadingCompletionConstraint.constant = -60
        unstrikeThroughLabel(self.titleLabel)
        unstrikeThroughLabel(self.courseLabel)
        unstrikeThroughLabel(self.dueDateLabel)
        unstrikeThroughLabel(self.dateLabel)
        self.titleLabel.textColor = UIColor.black
        self.courseLabel.textColor = UIColor.black
        self.dueDateLabel.textColor = UIColor.black
        self.dateLabel.textColor = UIColor.black
        self.cardView.alpha = 1.0
        self.isUserInteractionEnabled = true
        self.completionImageView.image = UIImage(named: "Grey Checkmark")
        self.completionImageView.layer.shadowRadius = 3.0
        self.completionImageView.layer.shadowOpacity = 0.25
        self.deletionImageView.image = UIImage(named: "Trash Can Grey")
        self.recognizer.isEnabled = true
        self.isSelected = false
        self.cardView.backgroundColor = UIColor.white
        self.facultyImageView.image = UIImage(named: "DefaultFaculty")
        self.repeatsImageView.isHidden = true
        self.repeatsImageView.image = #imageLiteral(resourceName: "Black Repeats")
    }
    
    func unstrikeThroughLabel(_ label: UILabel) {
        if (label.text != nil) {
            let attributedString = NSAttributedString(string: label.text!, attributes: [:])
            label.attributedText = attributedString
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - horizontal pan gesture methods
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        // 1
        if recognizer.state == .began {
            // when the gesture begins, record the current center location
            originalCenter = self.center
            //originalCenter = self.cardView.center
            self.bringSubview(toFront: self.contentView)
            self.originalAlpha = self.cardView.alpha

        }
        // 2
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            self.center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            //self.cardView.center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            // has the user dragged the item far enough to initiate a delete/complete?
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 4.0
            completeOnDrag = frame.origin.x > frame.size.width / 5.0
            closeToCompleteOnDrag = frame.origin.x > frame.size.width / 8.5
            
            if (deleteOnDragRelease) {
                //print(translation.x)
                if (self.deletionImageView.image != UIImage(named: "Trash Can Red")) {
                    UIView.transition(with: self.deletionImageView,
                                              duration: 0.2,
                                              options: UIViewAnimationOptions.transitionCrossDissolve,
                                              animations: { self.deletionImageView.image = UIImage(named: "Trash Can Red") },
                                              completion: nil)
                    self.deletionImageView.animation = "pop"
                    self.deletionImageView.curve = "spring"
                    self.deletionImageView.force = 0.6
                    self.deletionImageView.animationDuration = 0.9
                    //self.deletionImageView.repeatCount = Float.infinity
                    self.deletionImageView.animate()
                    UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.cardView.alpha = self.originalAlpha - 0.2 }, completion: nil) //reduce alpha of cardView by 0.2
                    
                    //UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveEaseOut, animations: { self.deletionImageView. }, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
                    self.deletionImageView.animation = "swing"
                    self.deletionImageView.force = 0.6
                    self.deletionImageView.duration = 1.2
                    self.deletionImageView.animateTo()
                }
            } else {
                if (self.deletionImageView.image != UIImage(named: "Trash Can Grey")) {
                    UIView.transition(with: self.deletionImageView,
                                              duration: 0.2,
                                              options: UIViewAnimationOptions.transitionCrossDissolve,
                                              animations: { self.deletionImageView.image = UIImage(named: "Trash Can Grey") },
                                              completion: nil)
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.cardView.alpha = self.originalAlpha }, completion: nil)
                    //self.deletionImageView.layer.removeAnimationForKey("pop")
                    //self.deletionImageView.repeatCount = 0
                    //self.deletionImageView.animation = ""
                    //self.deletionImageView.animateTo()
                }
            }
            
            if (self.task?.completed == false) {
                if (closeToCompleteOnDrag) {
                    if (self.completionImageView.image != UIImage(named: "Green Checkmark")) {
                        UIView.transition(with: self.completionImageView,
                                                  duration: 0.2,
                                                  options: UIViewAnimationOptions.transitionCrossDissolve,
                                                  animations: { self.completionImageView.image = UIImage(named: "Green Checkmark") },
                                                  completion: nil)
                        self.completionImageView.animation = "pop"
                        self.completionImageView.curve = "spring"
                        self.completionImageView.force = 0.6
                        self.completionImageView.animationDuration = 0.9
                        //self.completionImageView.repeatCount = Float.infinity
                        self.completionImageView.animate()
                        //UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { self.cardView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.85) }, completion: nil)
                    }
                } else {
                    if (self.completionImageView.image != UIImage(named: "Grey Checkmark")) {
                        UIView.transition(with: self.completionImageView,
                                                  duration: 0.2,
                                                  options: UIViewAnimationOptions.transitionCrossDissolve,
                                                  animations: { self.completionImageView.image = UIImage(named: "Grey Checkmark") },
                                                  completion: nil)
                        self.completionImageView.layer.removeAnimation(forKey: "pop")
                        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.cardView.backgroundColor = UIColor.white }, completion: nil)
                    }
                }
            }
            
            if (completeOnDrag) {
                let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                           width: bounds.size.width, height: bounds.size.height)
                recognizer.isEnabled = false
                if (self.task?.completed == true) {
                    self.completionImageView.isHidden = true
                }
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.curveEaseOut, animations: { self.frame = originalFrame }, completion: { finished in recognizer.isEnabled = true; self.completionImageView.isHidden = false })
                self.completionImageView.layer.removeAnimation(forKey: "pop")
                if (self.task?.completed == true) {
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.cardView.backgroundColor = UIColor.white }, completion: nil)
                } else {
                    //UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { self.cardView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.93) }, completion: nil)
                }
                self.deletionImageView.isHidden = true
                UIView.animate(withDuration: 0.07, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05) }, completion: {
                    finished in
                    UIView.animate(withDuration: 0.07, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) }, completion: {
                        finished in
                        UIView.animate(withDuration: 0.07, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) }, completion: { finished in self.deletionImageView.isHidden = false
                            if (self.delegate != nil && self.task != nil) {
                                // notify the delegate that this item should be moved
                                self.delegate!.moveTask(self, self.task!)
                            }
                        })
                    })
                    })
                self.completionImageView.image = UIImage(named: "Green Checkmark")
                //self.completionImageView.frame.origin.x = self.cardView.frame.origin.x //change constraint instead.
                self.leadingCompletionConstraint.constant = 32
                //complete cell.
                if (delegate != nil && task != nil) {
                    // notify the delegate that this item should be completed
                    delegate!.taskCompleted(task!)
                }
            }
        }
        // 3 //Remembered, state == .Cancelled when recognizer manually disabled.
        if recognizer.state == .ended {
            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                       width: bounds.size.width, height: bounds.size.height)
            if (!deleteOnDragRelease && !completeOnDrag) {
                // if the item is not being deleted, snap back to the original location
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.frame = originalFrame }, completion: nil)
                if (self.task?.completed == false) {
                    UIView.transition(with: self.completionImageView,
                                              duration: 0.2,
                                              options: UIViewAnimationOptions.transitionCrossDissolve,
                                              animations: { self.completionImageView.image = UIImage(named: "Grey Checkmark") },
                                              completion: nil)
                }
            }
            
            if (deleteOnDragRelease) {
                let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                           width: bounds.size.width, height: bounds.size.height)
                recognizer.isEnabled = false
                //Remove cell from tableView.
                if (delegate != nil && task != nil) {
                    // notify the delegate that this item should be deleted
                    delegate!.taskDeleted(task!)
                }
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    
    /*func imageWithBorderFromImage(source: UIImage) -> UIImage {
        let size  = source.size
        UIGraphicsBeginImageContext(size)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        source.drawInRect(rect, blendMode: .Normal, alpha: 1.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBStrokeColor(context,(255/255),(255/255),(255/255), 1.0)
        CGContextStrokeRect(context, rect)
        let borderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return borderedImage
    }*/
    

}
