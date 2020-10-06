//
//  ColorView.swift
//  B4Grad
//
//  Created by Sunil Zalavadiya on 12/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit

class ColorView: UIView {

    @IBOutlet var colorImageView: UIImageView!
    @IBOutlet var checkmarkImageView: UIImageView!
    @IBOutlet var btnColor: UIButton!
    
    //MARK: - Lifecycles
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    private func setupUI() {
        colorImageView.layer.cornerRadius = colorImageView.frame.height / 2.0
        colorImageView.layer.borderColor = UIColor.lightGray.cgColor
        colorImageView.layer.borderWidth = 1.0
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    //MARK: - Functions
    class func construct(owner: AnyObject) -> ColorView {
        var nibViews = Bundle.main.loadNibNamed("ColorView", owner: owner, options: nil)
        let colorView = nibViews?[0] as! ColorView
        return colorView
    }
}
