//
//  NotificationBannerView.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-06-09.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol NotificationBannerViewDelegate {
    // indicates that the button inside the NotificationBannerView was tapped
    func notificationBannerViewButtonTapped(_ b4GradNotification: B4GradNotification)
}

class NotificationBannerView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    var timer: Timer!
    var notificationObject: B4GradNotification?
    // The object that acts as delegate for this notification banner view.
    var delegate: NotificationBannerViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.visualEffectView.layer.cornerRadius = self.visualEffectView.frame.size.height / 7
        self.visualEffectView.layer.masksToBounds = true
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if (self.visualEffectView.frame.contains(point)) {
            return true
        }
        return false
    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        if (self.delegate != nil && self.notificationObject != nil) {
            // notify the delegate that this item should be moved
            self.delegate!.notificationBannerViewButtonTapped(self.notificationObject!)
        }
    }
    
    class func construct(_ owner : AnyObject, title : String, description : String, timer : Timer) -> NotificationBannerView {
        var nibViews = Bundle.main.loadNibNamed("NotificationBannerView", owner: owner, options: nil)
        let notificationBannerView = nibViews?[0] as! NotificationBannerView
        notificationBannerView.titleLabel.text = title
        //notificationBannerView.descriptionLabel.text = description
        notificationBannerView.timer = timer
        return notificationBannerView
    }

}
