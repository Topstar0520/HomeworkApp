//
//  PaletteTableViewHeaderFooterView.swift
//  B4Grad
//
//  Created by Sunil Zalavadiya on 12/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit

protocol PaletteTableViewHeaderFooterViewDelegate: class {
    func paletteTableViewHeaderFooterView(headerView: PaletteTableViewHeaderFooterView, didSelect color: UIColor, colorStaticValue: Int)
}

class PaletteTableViewHeaderFooterView: UITableViewHeaderFooterView {

    //MARK: - Outlets
    @IBOutlet var containerView: UIView!
    @IBOutlet var colorStackView: UIStackView!
    @IBOutlet var lblName: UILabel!
    
    //MARK: - Variables
    weak var delegate: PaletteTableViewHeaderFooterViewDelegate?
    var colors = [ColorDataModel]()
    var arrColorViews = [ColorView]()
    var colorStaticValue = 0
    
    //MARK: - Lifecycles
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        generateColorsArray()
        setupUI()
    }
    
    private func setupUI() {
        lblName.text = "B4Grad"//"Sandy Shoreside"
        for arrangedView in colorStackView.arrangedSubviews {
            arrangedView.removeFromSuperview()
        }
        arrColorViews.removeAll()
        
        for i in 0..<colors.count {
            let colorModel = colors[i]
            let colorView = ColorView.construct(owner: self)
            colorView.tag = i
            colorView.colorImageView.backgroundColor = colorModel.color
            colorView.btnColor.addTarget(self, action: #selector(onBtnColor(sender:)), for: .touchUpInside)
            colorStackView.addArrangedSubview(colorView)
            arrColorViews.append(colorView)
        }
    }
    
    func setColorStaticValue(colorStaticValue: Int) {
        self.colorStaticValue = colorStaticValue
        for i in 0..<colors.count {
            let colorModel = colors[i]
            let colorView = arrColorViews[i]
            if colorModel.colorStaticValue == colorStaticValue {
                colorView.btnColor.isSelected = true
            } else {
                colorView.btnColor.isSelected = false
            }
        }
    }
    
    private func generateColorsArray() {
        colors.removeAll()
        colors.append(contentsOf: ColorDataModel.getColorsArray())
    }
    
    //MARK: - Functions
    class func construct(owner: AnyObject) -> PaletteTableViewHeaderFooterView {
        var nibViews = Bundle.main.loadNibNamed("PaletteTableViewHeaderFooterView", owner: owner, options: nil)
        let sectionHeaderView = nibViews?[0] as! PaletteTableViewHeaderFooterView
        return sectionHeaderView
    }
    
    //MARK: - All button actions
    @IBAction private func onBtnColor(sender: UIButton) {
        for arrangedView in colorStackView.arrangedSubviews {
            if let colorView = arrangedView as? ColorView {
                colorView.btnColor.isSelected = false
            }
        }
        if let colorView = sender.superview as? ColorView {
            let colorModel = colors[colorView.tag]
            colorView.btnColor.isSelected = true
            delegate?.paletteTableViewHeaderFooterView(headerView: self, didSelect: colorModel.color, colorStaticValue: colorModel.colorStaticValue)
        }
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
