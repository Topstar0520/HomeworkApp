//
//  IndividualPaletteTableViewCell.swift
//  B4Grad
//
//  Created by Sunil Zalavadiya on 22/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit

protocol IndividualPaletteTableViewCellDelegate: class {
    func individualPaletteTableViewCell(cell: IndividualPaletteTableViewCell, didSelect color: UIColor, colorStaticValue: Int)
}

class IndividualPaletteTableViewCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet var containverView: UIView!
    @IBOutlet var btnColor1: UIButton!
    @IBOutlet var btnColor2: UIButton!
    @IBOutlet var btnColor3: UIButton!
    
    //MARK: - Variables
    weak var delegate: IndividualPaletteTableViewCellDelegate?
    var colors = [ColorDataModel]()
    var colorStaticValue = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    private func setupUI() {
        containverView.layer.cornerRadius = 10.0
        containverView.layer.masksToBounds = true
    }
    
    func configure(colorTypeModel: ColorTypeModel) {
        colors.removeAll()
        colors.append(contentsOf: colorTypeModel.colors)
        btnColor1.setBackgroundImage(colors[0].color.image(), for: .normal)
        btnColor2.setBackgroundImage(colors[1].color.image(), for: .normal)
        btnColor3.setBackgroundImage(colors[2].color.image(), for: .normal)
    }

    func checkForUsedColors(usedStaticColors: [Int]) {
        btnColor1.setImage(nil, for: .normal)
        btnColor2.setImage(nil, for: .normal)
        btnColor3.setImage(nil, for: .normal)
        
        let checkMarkImage = UIImage(named: "baseline_check")?.tintWithColor(UIColor.black.withAlphaComponent(0.1))
        if(usedStaticColors.contains(colors[0].colorStaticValue)) {
            btnColor1.setImage(checkMarkImage, for: .normal)
        }
        if(usedStaticColors.contains(colors[1].colorStaticValue)) {
            btnColor2.setImage(checkMarkImage, for: .normal)
        }
        if(usedStaticColors.contains(colors[2].colorStaticValue)) {
            btnColor3.setImage(checkMarkImage, for: .normal)
        }
    }
    
    func setColorStaticValue(colorStaticValue: Int) {
        self.colorStaticValue = colorStaticValue
        
        btnColor1.isSelected = false
        btnColor2.isSelected = false
        btnColor3.isSelected = false
        
        if colors[0].colorStaticValue == colorStaticValue {
            btnColor1.isSelected = true
        } else if colors[1].colorStaticValue == colorStaticValue {
            btnColor2.isSelected = true
        } else if colors[2].colorStaticValue == colorStaticValue {
            btnColor3.isSelected = true
        }
    }
    
    //MARK: - All Actions
    @IBAction func onBtnColor(_ sender: UIButton) {
        if sender == btnColor1 {
            delegate?.individualPaletteTableViewCell(cell: self, didSelect: colors[0].color, colorStaticValue: colors[0].colorStaticValue)
        } else if sender == btnColor2 {
            delegate?.individualPaletteTableViewCell(cell: self, didSelect: colors[1].color, colorStaticValue: colors[1].colorStaticValue)
        } else if sender == btnColor3 {
            delegate?.individualPaletteTableViewCell(cell: self, didSelect: colors[2].color, colorStaticValue: colors[2].colorStaticValue)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
