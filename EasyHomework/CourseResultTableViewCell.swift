//
//  CourseResultTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-04-29.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class CourseResultTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet var leftHandSideImageView: UIImageView!
    @IBOutlet var tagsCollectionView: UICollectionView!
    var dataArray = ["Popular!", "Fun", "Zzz"]
    @IBOutlet var tagsCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var courseLabel: UILabel!
    @IBOutlet var universityLabel: UILabel!
    @IBOutlet var facultyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.tagsCollectionView.dataSource = self
        self.tagsCollectionView.delegate = self
        //self.tagsCollectionViewHeightConstraint.constant = 50
        //Because the UICollectionView does not currently change height based on its contents & there appears to be random white space that appears, only 2 tags appear while the verticalSizeClass is in Regular mode.
        // Initialization code
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tagsCollectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //print(self.tagsCollectionView.contentSize)
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (traitCollection.verticalSizeClass == .regular && self.dataArray.count >= 3) {
            return 2
        }
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
        cell.tagLabel.text = dataArray[(indexPath as NSIndexPath).row]
        cell.tagImageView.image = UIImage(named: dataArray[(indexPath as NSIndexPath).row])
        //cell.layer.borderColor = UIColor.yellowColor().CGColor
        //cell.layer.borderWidth = 1
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = self.dataArray[(indexPath as NSIndexPath).row]
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
        label.sizeToFit()
        return CGSize(width: label.frame.width + 26 + 12, height: 19) //26 is width of UIImageView, 3 is the padding from leading/trailing constraints.
    }

}
