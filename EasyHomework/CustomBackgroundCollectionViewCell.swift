//
//  CustomBackgroundCollectionViewCell.swift
//  B4Grad
//
//  Created by Pham Thang on 9/17/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

protocol CustomBackgroundCollectionViewCellDelegate: NSObjectProtocol {
    func customBackgroundCollectionViewCellDidSelect(sender: CustomBackgroundCollectionViewCell)
}

class CustomBackgroundCollectionViewCell: UICollectionViewCell {
    weak var delegate: CustomBackgroundCollectionViewCellDelegate!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var bg: UIButton! //from master, delete if not used.

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }

    /*func setCheckMark(_ value: Bool) {
        checkMarkImageView.isHidden = value
    }*/

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.05) {
            self.transform = CGAffineTransform.identity
        }
        //setCheckMark(false)
        delegate.customBackgroundCollectionViewCellDidSelect(sender: self)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}
