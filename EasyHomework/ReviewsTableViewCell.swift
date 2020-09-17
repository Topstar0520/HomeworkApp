//
//  ReviewsTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-21.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class ReviewsTableViewCell: UITableViewCell, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var refreshIndicator: UIActivityIndicatorView!
    @IBOutlet var noReviewsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.delegate = self
        if #available(iOS 9.0, *) {
            (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = true
        }
        
        self.collectionView.alpha = 0.0
        self.noReviewsLabel.alpha = 0.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available(iOS 9.0, *) {
            let reviewHeaderView = self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(row: 0, section: 0)) as? ReviewCollectionReusableView
            if (scrollView.contentOffset.x > 4) {
                UIView.animate(withDuration: 0.4, animations: {
                    reviewHeaderView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
                    reviewHeaderView?.reviewLabel.textColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.6)
                })
            } else {
                UIView.animate(withDuration: 0.4, animations: {
                    reviewHeaderView?.backgroundColor = UIColor.clear
                    reviewHeaderView?.reviewLabel.textColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.25)
                })
            }
        }
    }

}
