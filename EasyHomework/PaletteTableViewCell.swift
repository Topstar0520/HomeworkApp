//
//  PaletteTableViewCell.swift
//  B4Grad
//
//  Created by Sunil Zalavadiya on 21/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit

protocol PaletteTableViewCellDelegate: class {
    func palettePaletteTableViewCell(cell: PaletteTableViewCell, didSelect color: UIColor, colorStaticValue: Int)
}

class PaletteTableViewCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet var containerView: UIView!
    @IBOutlet var colorStackView: UIStackView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var bgImageView: UIImageView!
    
    //MARK: - Variables
    weak var delegate: PaletteTableViewCellDelegate?
    var colors = [ColorDataModel]()
    var arrColorViews = [ColorView]()
    var colorStaticValue = 0
    
    //MARK: - Lifecycles
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    private func setupUI() {
        
    }
    
    func configure(colorTypeModel: ColorTypeModel) {
        colors.removeAll()
        colors.append(contentsOf: colorTypeModel.colors)
        lblName.text = colorTypeModel.paletteName
        bgImageView.image = UIImage(named: colorTypeModel.bgImageName)
        
        setupColors()
    }
    
    private func setupColors() {
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
    
    func checkForUsedColors(usedStaticColors: [Int]) {
        for i in 0..<colors.count {
            let colorModel = colors[i]
            let colorView = arrColorViews[i]
            colorView.btnColor.setImage(nil, for: .normal)
            if usedStaticColors.contains(colorModel.colorStaticValue) {
                colorView.btnColor.setImage(UIImage(named: "baseline_check")?.tintWithColor(UIColor.black.withAlphaComponent(0.1)), for: .normal)
            }
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
            delegate?.palettePaletteTableViewCell(cell: self, didSelect: colorModel.color, colorStaticValue: colorModel.colorStaticValue)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
