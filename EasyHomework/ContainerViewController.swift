//
//  ContainerViewController.swift
//  EasyHomework
//
//  Created by Anthony Giugno on 2016-02-14.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    @IBOutlet var backgroundImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.setupMotionEffects()
        loadCurrentBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCurrentBackground()
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
        }else {
            let imageName = BackgroundList[0]
            UserDefaults.standard.set(imageName, forKey: "custom_background")  //Integer
            setBackgroundImage(imageName)
        }
    }
    
    func setBackgroundImage(_ imageName: String) {
        if UIDevice.current.orientation.isLandscape {
            backgroundImageView.image = UIImage(named: imageName + "_landscape")
        }else {
            backgroundImageView.image = UIImage(named: imageName + "_porttrait")
        }
    }
    
    // MARK: - Motion Effect
    
    func setupMotionEffects() {
        let leftRightMin = -7.0, leftRightMax = 7.0
        let upDownMin = -7.0, upDownMax = 7.0
        
        let leftRight = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.tiltAlongHorizontalAxis) as UIInterpolatingMotionEffect
        
        leftRight.minimumRelativeValue = leftRightMin
        leftRight.maximumRelativeValue = leftRightMax
        
        let upDown = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.tiltAlongVerticalAxis) as UIInterpolatingMotionEffect
        
        upDown.minimumRelativeValue = upDownMin
        upDown.maximumRelativeValue = upDownMax
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [leftRight, upDown]
        
        //self.backgroundImageView.addMotionEffect(motionEffectGroup)
    }
    
    // MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        //Get backgroundImageView's name.
        //if (name == DefaultBackground3) {
        //  then set the alpha of the black uiView on top to look good. (default is 0.3)
        //}
        //check if landscape or Portrait, and change backgroundImageView based on that.
        
        /*if (UIApplication.shared.statusBarOrientation.isLandscape) {
            self.backgroundImageView.image = UIImage(named: "DefaultBackground1")
        } else {
            self.backgroundImageView.image = UIImage(named: "DefaultBackground1")
        }*/
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        loadCurrentBackground()
    }
}
