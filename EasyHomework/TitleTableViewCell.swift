//
//  TitleTableViewCell.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-22.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class TitleTableViewCell: UITableViewCell {

    typealias action = () -> Void

    @IBOutlet var titleTextView: SZTextView!
    @IBOutlet var clearButton: UIButton!

    var clearAction: action?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextView.tintColor = UIColor(hex: "7A7A7A")
        titleTextView.placeholderTextColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.3)
//        titleTextView.placeholder = "Assignment"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func clearButtonTapped(_ sender: Any) {
//        titleTextView.text = ""
        clearAction?()
    }

}
