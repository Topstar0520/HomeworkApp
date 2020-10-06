//
//  CustomBackgroundViewController.swift
//  B4Grad
//
//  Created by Pham Thang on 9/17/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

class CustomBackgroundViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CustomBackgroundCollectionViewCellDelegate {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var bgImageCollectionView: UICollectionView!
    private var curSelectedCellIndex: IndexPath?
    private var selectedImage:String!
    private let itemEdgeInset = CGFloat(8)

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
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
    }

    // MARK: - Background

    func loadCurrentBackground() {
        if let background =  UserDefaults.standard.string(forKey: "custom_background") {
            setBackgroundImage(background)
            selectedImage = background
        } else {
            bgImageView.image = UIImage(named: "DefaultBackground1")
            //selectedImage = BackgroundList[0]
            //setBackgroundImage(selectedImage)
            //saveBackground(selectedImage)
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
        cell.cellImageView.image = UIImage(named: iconName)
        cell.delegate = self
        return cell
    }

    // MARK: CustomBackgroundCollectionViewCell Delegate

    func customBackgroundCollectionViewCellDidSelect(sender: CustomBackgroundCollectionViewCell) {
        if let indexPath = bgImageCollectionView.indexPath(for: sender) {
            selectedImage = BackgroundList[indexPath.item]
            UIView.transition(with: bgImageView, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.setBackgroundImage(self.selectedImage)
            }, completion: nil)
            saveBackground(selectedImage)
            NotificationCenter.default.post(name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil) //to update backgroundView if necessary
            if let selectedIndex = curSelectedCellIndex {
                if let curSelectedCell = bgImageCollectionView.cellForItem(at: selectedIndex) as? CustomBackgroundCollectionViewCell {
                    //curSelectedCell.setCheckMark(true) //removed checkmark because it is unnecessary.
                }
            }
            curSelectedCellIndex = indexPath
        }
    }
}
