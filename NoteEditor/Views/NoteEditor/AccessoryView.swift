//
//  AccessoryView.swift
//  NoteEditor
//
//  Created by Pham Thang on 12/14/18.
//  Copyright © 2018 Marko Rankovic. All rights reserved.
//

import UIKit

protocol AccessoryViewDelegate: NSObjectProtocol {
    func accessoryViewDoEditAction(_ index: Int)
}
class AccessoryView: UIView {
    weak var delegate: AccessoryViewDelegate!
    @IBOutlet weak var keyboardButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func doEditAction(_ sender: UIButton) {
        setSelectedButton(sender)
        let touchPoint = collectionView.convert(CGPoint.zero, from: sender)
        if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
            delegate.accessoryViewDoEditAction(indexPath.item)
        }
    }
    
    @objc func setSelectedButton(_ button: UIButton,_ isSelected :Bool = true) {
        button.isSelected = !button.isSelected
        if isSelected {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                //self.setSelectedButton(button, false)
            }
        }
    }
    
    
}
