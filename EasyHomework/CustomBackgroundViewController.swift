//
//  CustomBackgroundViewController.swift
//  B4Grad
//
//  Created by Pham Thang on 9/17/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

class CustomBackgroundViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var bgImageCollectionView: UICollectionView!
    private var curSelectedCellIndex: Int?
    private var selectedImage:String!
    private let itemEdgeInset = CGFloat(8)
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgImageCollectionView.allowsMultipleSelection = false
        loadCurrentBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        loadCurrentBackground()
        bgImageCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Background
    
    func loadCurrentBackground() {
        if let background =  UserDefaults.standard.string(forKey: "custom_background") {
            setBackgroundImage(background)
            selectedImage = background
        }else {
            selectedImage = BackgroundList[0]
            setBackgroundImage(selectedImage)
            saveBackground(selectedImage)
        }
    }
    
    func saveBackground(_ imageName: String) {
        UserDefaults.standard.set(imageName, forKey: "custom_background")
    }
    
    @IBAction func saveToExit() {
        saveBackground(selectedImage)
    }
    
    func setBackgroundImage(_ imageName: String) {
        if UIDevice.current.orientation.isLandscape {
            bgImageView.image = UIImage(named: imageName + "_landscape")
        }else {
            bgImageView.image = UIImage(named: imageName + "_porttrait")
        }
    }
    
    // MARK: - CollectionView
    
    // MARK: CollectionView Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.height - itemEdgeInset
        return CGSize(width: width, height: width)
    }
    
    // MARK: CollectionView Datasources
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BackgroundList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomBackgroundCollectionViewCellIdentifier", for: indexPath) as! CustomBackgroundCollectionViewCell
        let iconName = BackgroundList[indexPath.item] + "_icon"
        cell.bg.setBackgroundImage(UIImage(named: iconName), for: .normal)
        cell.bg.isSelected = false
        if let selectedIndex = curSelectedCellIndex {
            if selectedIndex == indexPath.item {
                cell.bg.isSelected = true
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let curSelectedCell = bgImageCollectionView.cellForItem(at: indexPath) as? CustomBackgroundCollectionViewCell {
            curSelectedCell.bg.isSelected = true
        }
        curSelectedCellIndex = indexPath.item
        self.selectedImage = BackgroundList[indexPath.item]
        UIView.transition(with: self.bgImageView, duration: 0.7, options: .transitionCrossDissolve, animations: {
            self.setBackgroundImage(self.selectedImage)
        }, completion: nil)
        self.saveBackground(self.selectedImage)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let curSelectedCell = bgImageCollectionView.cellForItem(at: indexPath) as? CustomBackgroundCollectionViewCell {
            curSelectedCell.bg.isSelected = false
            if let selectedIndex = curSelectedCellIndex {
                if indexPath.item == selectedIndex {
                    curSelectedCellIndex = nil
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let curSelectedCell = cell as? CustomBackgroundCollectionViewCell  else { return }
        curSelectedCell.bg.isSelected = false
        if let selectedIndex = curSelectedCellIndex {
            if selectedIndex == indexPath.item {
                curSelectedCell.bg.isSelected = true
            }
        }
    }
}
