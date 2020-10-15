//
//  RoundEdgedButton.swift
//  B4Grad
//
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit

class RoundEdgedButton: UIButton {
    
    var activityView: UIActivityIndicatorView?
    
    override func awakeFromNib() {
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.addSubview(self.activityView!)
        self.activityView?.translatesAutoresizingMaskIntoConstraints = false
        self.centerActivityIndicatorInButton()
        self.activityView?.startAnimating()
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: self.activityView!, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: self.activityView!, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
    
    @IBInspectable var supportsSecondaryText: Bool = false {
        didSet {
            if supportsSecondaryText {
                addTheSecondaryLabel()
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor = .white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = 2.0
            self.secondaryLabel?.backgroundColor = borderColor
        }
    }
    
    @IBInspectable var selectedBorderColor: UIColor = .white {
        didSet {
            
        }
    }
    
    @IBInspectable var secondaryTextBackgroundColor: UIColor = .white {
        didSet {
            secondaryLabel?.backgroundColor = secondaryTextBackgroundColor
        }
    }

    @IBInspectable var secondaryText: String = "BUY" {
        didSet {
            secondaryLabel?.text = secondaryText
        }
    }
    
    @IBInspectable var secondaryTextColor: UIColor = .white {
        didSet {
            secondaryLabel?.textColor = secondaryTextColor
        }
    }
    
    private var secondaryLabel: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 2.0
    }
    
    private func addTheSecondaryLabel() {
        secondaryLabel = UILabel()
        self.addSubview(secondaryLabel!)
        secondaryLabel?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: secondaryLabel!, attribute: NSLayoutConstraint.Attribute.rightMargin, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.rightMargin, multiplier: 1, constant: -5).isActive = true
        NSLayoutConstraint(item: secondaryLabel!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.26, constant: 1).isActive = true
        NSLayoutConstraint(item: secondaryLabel!, attribute: NSLayoutConstraint.Attribute.bottomMargin, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottomMargin, multiplier: 1, constant: -5).isActive = true
        NSLayoutConstraint(item: secondaryLabel!, attribute: NSLayoutConstraint.Attribute.topMargin, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.topMargin, multiplier: 1, constant: 5).isActive = true
        secondaryLabel?.backgroundColor = .white
        secondaryLabel?.clipsToBounds = true
        secondaryLabel?.text = secondaryText
        secondaryLabel?.textColor = .black
        secondaryLabel?.textAlignment = .center
        secondaryLabel?.font = UIFont.systemFont(ofSize: 15, weight: .black)
        secondaryLabel?.minimumScaleFactor = 0.5
        secondaryLabel?.numberOfLines = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        secondaryLabel?.layer.cornerRadius = secondaryLabel!.bounds.size.height/2
        self.layer.cornerRadius = self.bounds.height/2
        var labelFontSize = self.bounds.width * 0.25
        if UIDevice.current.userInterfaceIdiom == .pad {
            if labelFontSize > 15 {
                labelFontSize = 15
            }
        } else {
            if labelFontSize > 15 {
                labelFontSize = 15
            }
        }
        self.titleLabel?.font = UIFont.systemFont(ofSize: labelFontSize, weight: .semibold)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.borderColor = selectedBorderColor.cgColor
                self.layer.borderWidth = 2.0
                self.secondaryLabel?.backgroundColor = selectedBorderColor
                self.secondaryLabel?.text = "START"
                self.secondaryLabel?.textColor = .white
                self.setTitleColor(.white, for: .normal)
                self.setTitleColor(.white, for: .selected)
            } else {
                self.layer.borderColor = borderColor.cgColor
                self.layer.borderWidth = 2.0
                self.secondaryLabel?.backgroundColor = borderColor
                self.secondaryLabel?.text = "BUY"
                self.secondaryLabel?.textColor = .black
                self.setTitleColor(.white, for: .normal)
                self.setTitleColor(.white, for: .selected)
            }
        }
    }
}
