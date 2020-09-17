//
//  SubTaskTableViewCell.swift
//  B4Grad
//
//  Created by Amritpal Singh on 8/20/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//   

import UIKit

protocol SubTaskCellDelegate {
    func didTapSubscribeButton()
    func deleteEmptySubTask(cell: SubTaskTableViewCell)
    func didChangeHeight(_ height: CGFloat, cell: SubTaskTableViewCell)
    func didTapDone(subTask: String, cell: SubTaskTableViewCell)
    func didTapCompleteSubTask(sender: UIButton, cell: SubTaskTableViewCell)
}

class SubTaskTableViewCell: UITableViewCell {

    @IBOutlet weak var checkMarkButton: UIButton!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var subTaskTextView: SZTextView!
//    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

    var delegate: SubTaskCellDelegate?
//    var indexPath: IndexPath!
//    var subTask: SubTask?

    override func awakeFromNib() {
        super.awakeFromNib()
        subTaskTextView.tintColor = UIColor(hex: "7A7A7A")
        subTaskTextView.placeholderTextColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func checkMarkButtonTapped(_ sender: UIButton) {
        delegate?.didTapCompleteSubTask(sender: sender, cell: self)
    }

    @IBAction func subscribeButtonTapped(_ sender: UIButton) {
        delegate?.didTapSubscribeButton()
    }

}

extension SubTaskTableViewCell: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {

        if checkMarkButton.imageView?.image == #imageLiteral(resourceName: "plus_light") || checkMarkButton.imageView?.image == #imageLiteral(resourceName: "plus_dark") {
            checkMarkButton.setImage(#imageLiteral(resourceName: "plus_dark"), for: .normal)
        }

    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if checkMarkButton.imageView?.image == #imageLiteral(resourceName: "plus_light") || checkMarkButton.imageView?.image == #imageLiteral(resourceName: "plus_dark") {
            checkMarkButton.setImage(#imageLiteral(resourceName: "plus_light") , for: .normal)
        }
    }

    func textViewDidChange(_ textView: UITextView) {

        /* Calculate the frame size required to display the contained
         content */
        let fixedWidth = textView.frame.size.width

        // Our base height
        let baseHeight: CGFloat = 35

        if textView.text.last == "\n" {
            textView.text.removeLast()

            if textView.text == "" {
                delegate?.deleteEmptySubTask(cell: self)
                textView.resignFirstResponder()
            } else {
                delegate?.didTapDone(subTask: textView.text, cell: self)
            }
        }

        if textView.text != "" {
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
            let height: CGFloat = newSize.height > baseHeight ? newSize.height : baseHeight

            delegate?.didChangeHeight(height, cell: self)
        }

    }

}
